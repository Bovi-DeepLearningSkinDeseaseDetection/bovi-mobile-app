import 'dart:async';

import '../../../../iam/domain/exceptions/auth_exceptions.dart';
import '../../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../../../../shared/domain/exceptions/network_unavailable_exception.dart';
import '../../../../shared/infrastructure/network/api_client.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/repositories/evaluation_sync_repository.dart';
import '../../../domain/services/evaluation_sync_gateway.dart';
import '../outboundservices/external_iam_service.dart';

/// How a sync run ended.
enum SyncOutcome {
  /// Everything that could go up went up.
  completed,

  /// No connection (or it dropped): the rest is retried later.
  offline,

  /// No valid session: the farmer must sign in again.
  signedOut,
}

class SyncReport {
  final SyncOutcome outcome;
  final int synced;
  final int failed;

  const SyncReport(this.outcome, {this.synced = 0, this.failed = 0});
}

/// ClinicalSyncModule on the phone (HU12, RF6): backs up the evaluations
/// saved offline. Order of each run: animals, then for each batch of 20
/// evaluations the upload URLs, the photos straight to S3 and the data.
///
/// Nothing is lost nor duplicated (RNF10): an evaluation changes to
/// "Sincronizado" only when the backend confirms it, a dropped connection
/// leaves the rest pending, and a resent evaluation answers `duplicate`.
class CloudSyncService {
  /// Time the farmer has to assign the animal right after the analysis.
  static const settleTime = Duration(minutes: 2);
  static const _parallelUploads = 4;

  final EvaluationSyncRepository _evaluations;
  final EvaluationSyncGateway _gateway;
  final ExternalIamService _iam;
  final LivestockContextFacade _livestock;
  final DateTime Function() _clock;
  Future<SyncReport>? _running;

  CloudSyncService(
    this._evaluations,
    this._gateway,
    this._iam,
    this._livestock, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Runs a sync; a call while one runs gets that same run.
  Future<SyncReport> syncNow() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<SyncReport> _run() async {
    var synced = 0;
    var failed = 0;
    try {
      final token = await _iam.accessToken();
      final owner = await _iam.currentFarmerId();
      if (owner == null) return const SyncReport(SyncOutcome.signedOut);

      await _livestock.syncPendingAnimals(ownerId: owner, token: token);

      final pending = await _evaluations.pendingSync(
        owner,
        changedBefore: _clock().subtract(settleTime),
      );
      for (var i = 0; i < pending.length; i += EvaluationSyncGateway.maxBatch) {
        final batch = pending.skip(i).take(EvaluationSyncGateway.maxBatch);
        final result = await _syncBatch(token, owner, batch.toList());
        synced += result.synced;
        failed += result.failed;
      }
      return SyncReport(SyncOutcome.completed, synced: synced, failed: failed);
    } on SessionExpiredException {
      return SyncReport(SyncOutcome.signedOut, synced: synced, failed: failed);
    } on NetworkUnavailableException {
      return SyncReport(SyncOutcome.offline, synced: synced, failed: failed);
    } on ApiException catch (error) {
      // 401: the token was revoked; anything else (503...) is retried later.
      final outcome = error.isUnauthorized
          ? SyncOutcome.signedOut
          : SyncOutcome.offline;
      return SyncReport(outcome, synced: synced, failed: failed);
    }
  }

  Future<({int synced, int failed})> _syncBatch(
    String token,
    String owner,
    List<Evaluation> batch,
  ) async {
    var failed = 0;
    final byId = {for (final e in batch) e.uuid: e};
    final confirmed = <String>[];

    // 1. Upload URLs. An evaluation already in the cloud needs nothing more.
    final tickets = await _gateway.requestUploads(token, byId.keys.toList());
    final ready = <UploadTicket>[];
    for (final ticket in tickets) {
      switch (ticket.status) {
        case UploadTicketStatus.alreadySynced:
          confirmed.add(ticket.evaluationId);
        case UploadTicketStatus.rejected:
          await _evaluations.markFailed(
            ticket.evaluationId,
            owner,
            'El identificador de la evaluación ya está en uso.',
          );
          failed++;
        case UploadTicketStatus.ready:
          ready.add(ticket);
      }
    }

    // 2. Photos straight to S3, a few at a time.
    final uploaded = <Evaluation>[];
    for (var i = 0; i < ready.length; i += _parallelUploads) {
      final group = ready.skip(i).take(_parallelUploads);
      await Future.wait(
        group.map((ticket) async {
          final evaluation = byId[ticket.evaluationId]!;
          try {
            await _gateway.uploadPhoto(ticket, evaluation.imagePath);
            uploaded.add(evaluation);
          } on PhotoRejectedException {
            await _evaluations.markFailed(
              evaluation.uuid,
              owner,
              PhotoRejectedException.message,
            );
            failed++;
          }
        }),
      );
    }

    // 3. The data, with the cloud id of each animal. An evaluation whose
    // animal is not in the cloud yet waits for the next run.
    final uploads = <EvaluationUpload>[];
    for (final evaluation in uploaded) {
      final animalId = evaluation.animalId;
      final animalUuid = animalId == null
          ? null
          : await _livestock.syncedAnimalUuid(animalId);
      if (animalId != null && animalUuid == null) continue;
      uploads.add(EvaluationUpload(evaluation, animalUuid));
    }
    if (uploads.isNotEmpty) {
      for (final result in await _gateway.sync(token, uploads)) {
        if (result.isSynced) {
          confirmed.add(result.id);
        } else if (result.isFailed) {
          await _evaluations.markFailed(
            result.id,
            owner,
            result.message ?? 'El servidor rechazó la evaluación.',
          );
          failed++;
        }
      }
    }

    await _evaluations.markSynced(confirmed, owner, _clock());
    return (synced: confirmed.length, failed: failed);
  }
}
