import 'dart:async';

import '../../../../iam/domain/exceptions/auth_exceptions.dart';
import '../../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../../../../shared/domain/exceptions/network_unavailable_exception.dart';
import '../../../../shared/domain/model/sync_status.dart';
import '../../../../shared/infrastructure/network/api_client.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../domain/repositories/evaluation_restore_repository.dart';
import '../../../domain/services/evaluation_photo_store.dart';
import '../../../domain/services/history_restore_gateway.dart';
import '../outboundservices/external_iam_service.dart';

enum RestoreOutcome {
  /// Everything in the cloud is on the phone.
  completed,

  /// The connection dropped: restoring again continues where it stopped.
  offline,

  /// No valid session.
  signedOut,
}

class RestoreProgress {
  /// Evaluations of the farmer in the cloud.
  final int total;

  /// Already on the phone, restored now or before.
  final int done;

  const RestoreProgress(this.done, this.total);

  double get fraction => total == 0 ? 1 : done / total;
}

class RestoreReport {
  final RestoreOutcome outcome;
  final int restored;
  final int animals;

  /// Evaluations whose photo is no longer in the cloud: not restored.
  final int missingPhotos;

  const RestoreReport(
    this.outcome, {
    this.restored = 0,
    this.animals = 0,
    this.missingPhotos = 0,
  });
}

/// Brings the farmer's history back to a new phone or after reinstalling
/// the app (HU13, RF13): animals first, then the evaluations newest first,
/// each with its photo downloaded straight from S3.
///
/// Only the farmer's own data comes back: the backend answers by the token
/// (scenario 3). Everything is saved as synced, so the sync never sends it
/// again, and an evaluation already on the phone is skipped: a cut restore
/// simply continues the next time.
class HistoryRestoreService {
  static const _pageSize = 50;
  static const _parallelDownloads = 6;

  final EvaluationRepository _evaluations;
  final EvaluationRestoreRepository _local;
  final HistoryRestoreGateway _gateway;
  final EvaluationPhotoStore _photos;
  final ExternalIamService _iam;
  final LivestockContextFacade _livestock;

  const HistoryRestoreService(
    this._evaluations,
    this._local,
    this._gateway,
    this._photos,
    this._iam,
    this._livestock,
  );

  /// Evaluations to restore when this phone has none of the farmer's but
  /// the cloud does (scenario 1); 0 otherwise or without connection.
  Future<int> pendingToRestore() async {
    try {
      final owner = await _iam.currentFarmerId();
      if (owner == null || await _local.countOwnedBy(owner) > 0) return 0;
      final token = await _iam.accessToken();
      return (await _gateway.fetchEvaluations(token, limit: 1)).total;
    } on SessionExpiredException {
      return 0;
    } on NetworkUnavailableException {
      return 0;
    } on ApiException {
      return 0;
    }
  }

  /// Evaluations of the farmer in the cloud, or null without connection.
  Future<int?> cloudCount() async {
    try {
      final token = await _iam.accessToken();
      return (await _gateway.fetchEvaluations(token, limit: 1)).total;
    } on SessionExpiredException {
      return null;
    } on NetworkUnavailableException {
      return null;
    } on ApiException {
      return null;
    }
  }

  Future<RestoreReport> restore({
    void Function(RestoreProgress progress)? onProgress,
  }) async {
    var restored = 0;
    var animals = 0;
    var missing = 0;
    try {
      final token = await _iam.accessToken();
      final owner = await _iam.currentFarmerId();
      if (owner == null) return const RestoreReport(RestoreOutcome.signedOut);

      final herd = await _livestock.restoreAnimals(
        ownerId: owner,
        token: token,
      );
      animals = herd.length;

      var done = 0;
      String? cursor;
      do {
        final page = await _gateway.fetchEvaluations(
          token,
          cursor: cursor,
          limit: _pageSize,
        );
        final missingHere = <RemoteEvaluation>[];
        for (final remote in page.items) {
          if (await _local.exists(remote.id)) {
            done++;
          } else {
            missingHere.add(remote);
          }
        }
        onProgress?.call(RestoreProgress(done, page.total));
        for (var i = 0; i < missingHere.length; i += _parallelDownloads) {
          final group = missingHere.skip(i).take(_parallelDownloads);
          final saved = await Future.wait(
            group.map((remote) => _restoreOne(remote, owner, herd)),
          );
          restored += saved.where((ok) => ok).length;
          missing += saved.where((ok) => !ok).length;
          done += saved.length;
          onProgress?.call(RestoreProgress(done, page.total));
        }
        cursor = page.nextCursor;
      } while (cursor != null);

      return RestoreReport(
        RestoreOutcome.completed,
        restored: restored,
        animals: animals,
        missingPhotos: missing,
      );
    } on SessionExpiredException {
      return RestoreReport(RestoreOutcome.signedOut, restored: restored);
    } on NetworkUnavailableException {
      return RestoreReport(RestoreOutcome.offline, restored: restored);
    } on ApiException catch (error) {
      return RestoreReport(
        error.isUnauthorized
            ? RestoreOutcome.signedOut
            : RestoreOutcome.offline,
        restored: restored,
      );
    }
  }

  /// False when the photo is no longer in the cloud.
  Future<bool> _restoreOne(
    RemoteEvaluation remote,
    String owner,
    Map<String, AnimalSummary> herd,
  ) async {
    try {
      final bytes = await _gateway.downloadPhoto(remote.imageUrl);
      final files = await _photos.saveDownloaded(bytes, remote.id);
      final animal = remote.animalUuid == null ? null : herd[remote.animalUuid];
      await _evaluations.save(
        Evaluation(
          uuid: remote.id,
          createdAt: remote.evaluatedAt,
          imagePath: await _photos.pathOf(files.image),
          thumbnailPath: await _photos.pathOf(files.thumbnail),
          origin: remote.origin,
          result: remote.result,
          clinicalCodes: remote.clinicalCodes,
          catalogVersion: remote.catalogVersion,
          animalId: animal?.id,
          animalEarTag: animal?.earTag,
          bodyZone: animal == null ? null : remote.bodyZone,
          syncStatus: SyncStatus.synced,
          ownerId: owner,
        ),
      );
      return true;
    } on PhotoMissingException {
      return false;
    }
  }
}
