import 'package:bov_mobile_app/clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'package:bov_mobile_app/clinical/domain/services/evaluation_sync_gateway.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../iam/iam_fakes.dart' as iam;
import 'sync_fakes.dart';

void main() {
  late SyncHarness h;

  setUp(() => h = SyncHarness());

  group('HU12, scenarios 1 and 2: back up and confirm', () {
    test('photos go to S3 and then the data; all end synced', () async {
      for (final id in ['e1', 'e2', 'e3']) {
        h.evaluations.add(evaluation(id, owner: ownerId));
      }

      final report = await h.service.syncNow();

      expect(report.outcome, SyncOutcome.completed);
      expect(report.synced, 3);
      expect(h.backend.calls, [
        'upload-url',
        'photo',
        'photo',
        'photo',
        'sync',
      ]);
      expect(h.backend.saved.keys, unorderedEquals(['e1', 'e2', 'e3']));
      for (final id in ['e1', 'e2', 'e3']) {
        expect(h.evaluations.statusOf(id), SyncStatus.synced);
      }
    });

    test('batches of at most 20 evaluations', () async {
      for (var i = 0; i < 45; i++) {
        h.evaluations.add(evaluation('e$i', owner: ownerId));
      }

      final report = await h.service.syncNow();

      expect(report.synced, 45);
      expect(h.backend.batchSizes, [20, 20, 5]);
    });

    test(
      'a just analyzed evaluation waits so the animal can be assigned',
      () async {
        h.evaluations.add(evaluation('reciente', owner: ownerId), changed: now);

        await h.service.syncNow();

        expect(h.backend.calls, isEmpty);
        expect(h.evaluations.statusOf('reciente'), SyncStatus.pending);
      },
    );

    test('nothing pending: no request to the backend', () async {
      final report = await h.service.syncNow();

      expect(report.outcome, SyncOutcome.completed);
      expect(h.backend.calls, isEmpty);
    });
  });

  group('HU12, scenario 3: connection cut, no loss nor duplicates', () {
    test(
      'a dropped upload leaves the rest pending; the retry completes',
      () async {
        for (var i = 0; i < 25; i++) {
          h.evaluations.add(evaluation('e$i', owner: ownerId));
        }
        h.backend.dropConnectionOn.add('e22'); // in the second batch

        final first = await h.service.syncNow();

        expect(first.outcome, SyncOutcome.offline);
        expect(first.synced, 20);
        expect(h.evaluations.statusOf('e5'), SyncStatus.synced);
        expect(h.evaluations.statusOf('e22'), SyncStatus.pending);

        final second = await h.service.syncNow();

        expect(second.outcome, SyncOutcome.completed);
        expect(second.synced, 5);
        expect(h.backend.saved, hasLength(25));
        expect(
          h.evaluations.items.values.every(
            (e) => e.syncStatus == SyncStatus.synced,
          ),
          isTrue,
        );
      },
    );

    test(
      'an evaluation saved before the cut is confirmed, not copied',
      () async {
        h.evaluations.add(evaluation('e1', owner: ownerId));
        // The backend saved it but the answer never reached the phone.
        h.backend.saved['e1'] = EvaluationUpload(evaluation('e1'), null);

        final report = await h.service.syncNow();

        expect(report.synced, 1);
        expect(h.backend.calls, ['upload-url']); // no photo, no data again
        expect(h.evaluations.statusOf('e1'), SyncStatus.synced);
      },
    );

    test(
      'a call while a sync runs joins it instead of starting another',
      () async {
        for (var i = 0; i < 3; i++) {
          h.evaluations.add(evaluation('e$i', owner: ownerId));
        }

        await Future.wait([h.service.syncNow(), h.service.syncNow()]);

        expect(h.backend.calls.where((c) => c == 'sync'), hasLength(1));
      },
    );
  });

  group('Rejections', () {
    test('a rejection the next run can solve keeps it pending', () async {
      h.evaluations.add(evaluation('e1', owner: ownerId));
      h.backend.rejections['e1'] = (
        'animal_no_sincronizado',
        'Falta el animal',
      );

      await h.service.syncNow();

      expect(h.evaluations.statusOf('e1'), SyncStatus.pending);
    });

    test(
      'an invalid evaluation fails with the message of the backend',
      () async {
        h.evaluations.add(evaluation('e1', owner: ownerId));
        h.backend.rejections['e1'] = (
          'evaluacion_invalida',
          'Las probabilidades deben sumar 1.',
        );

        final report = await h.service.syncNow();

        expect(report.failed, 1);
        expect(h.evaluations.statusOf('e1'), SyncStatus.failed);
        expect(
          h.evaluations.items['e1']!.syncError,
          'Las probabilidades deben sumar 1.',
        );
      },
    );

    test('a photo S3 refuses fails without stopping the others', () async {
      h.evaluations.add(evaluation('grande', owner: ownerId));
      h.evaluations.add(evaluation('normal', owner: ownerId));
      h.backend.rejectedPhotos.add('grande');

      await h.service.syncNow();

      expect(h.evaluations.statusOf('grande'), SyncStatus.failed);
      expect(
        h.evaluations.items['grande']!.syncError,
        PhotoRejectedException.message,
      );
      expect(h.evaluations.statusOf('normal'), SyncStatus.synced);
    });
  });

  group('Animals (HU15)', () {
    test('the animal goes first and the evaluation points to it', () async {
      h.animals.add(1, 'PE-0012', owner: ownerId);
      h.evaluations.add(evaluation('e1', owner: ownerId, animalId: 1));

      await h.service.syncNow();

      expect(h.animals.byId(1).syncStatus, SyncStatus.synced);
      final sent = h.backend.saved['e1']!;
      expect(sent.animalUuid, 'animal-1');
    });

    test('an ear tag already in the cloud takes the cloud id', () async {
      h.animalBackend.savedTags['PE-0012'] = 'id-del-otro-celular';
      h.animals.add(1, 'PE-0012', owner: ownerId);
      h.evaluations.add(evaluation('e1', owner: ownerId, animalId: 1));

      await h.service.syncNow();

      expect(h.animals.byId(1).uuid, 'id-del-otro-celular');
      expect(h.backend.saved['e1']!.animalUuid, 'id-del-otro-celular');
    });

    test('an evaluation of an animal not in the cloud waits', () async {
      h.animals.add(1, 'PE-0012', owner: ownerId);
      h.animalBackend.rejected['animal-1'] = ('reintentar', 'Reintente');
      h.evaluations.add(evaluation('e1', owner: ownerId, animalId: 1));

      await h.service.syncNow();

      expect(h.backend.saved, isEmpty);
      expect(h.evaluations.statusOf('e1'), SyncStatus.pending);
    });
  });

  group('Whose data (HU14)', () {
    test('records of another account on this phone are not sent', () async {
      h.evaluations.add(evaluation('mia', owner: ownerId));
      h.evaluations.add(evaluation('ajena', owner: otherOwner));

      await h.service.syncNow();

      expect(h.backend.saved.keys, ['mia']);
      expect(h.evaluations.statusOf('ajena'), SyncStatus.pending);
    });

    test('records saved before the accounts existed are taken', () async {
      h.evaluations.add(evaluation('antigua'));

      await h.service.syncNow();

      expect(h.evaluations.items['antigua']!.ownerId, ownerId);
      expect(h.evaluations.statusOf('antigua'), SyncStatus.synced);
    });
  });

  group('Session', () {
    test('without a session nothing is sent', () async {
      h.sessions.stored = null;
      h.evaluations.add(evaluation('e1', owner: ownerId));

      final report = await h.service.syncNow();

      expect(report.outcome, SyncOutcome.signedOut);
      expect(h.backend.calls, isEmpty);
    });

    test('a token the backend revoked ends the run as signed out', () async {
      h.evaluations.add(evaluation('e1', owner: ownerId));
      h.backend.revokeToken = true;

      final report = await h.service.syncNow();

      expect(report.outcome, SyncOutcome.signedOut);
      expect(h.evaluations.statusOf('e1'), SyncStatus.pending);
    });

    test('an expired token without internet means offline', () async {
      h.sessions.stored = iam.session(accessLeft: const Duration(hours: -2));
      h.gateway.failure = iam.offline;
      h.evaluations.add(evaluation('e1', owner: ownerId));

      final report = await h.service.syncNow();

      expect(report.outcome, SyncOutcome.offline);
    });
  });
}
