import 'package:bov_mobile_app/clinical/application/internal/commandservices/history_restore_service.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/body_zone.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

import 'restore_fakes.dart';
import 'sync_fakes.dart';

void main() {
  late RestoreHarness h;

  setUp(() => h = RestoreHarness());

  group('HU13, scenario 1: restore on a phone without data', () {
    test('animals, evaluations and photos come back as synced', () async {
      h.animalCloud.animals.add(cloudAnimal('vaca-1', 'PE-0012'));
      h.cloud.evaluations
        ..add(remote(1, animalUuid: 'vaca-1'))
        ..add(remote(2));

      final report = await h.service.restore();

      expect(report.outcome, RestoreOutcome.completed);
      expect(report.restored, 2);
      expect(report.animals, 1);
      final first = h.evaluations.items['cloud-1']!;
      expect(first.syncStatus, SyncStatus.synced);
      expect(first.ownerId, ownerId);
      expect(first.imagePath, '/fotos/cloud-1.jpg');
      expect(first.thumbnailPath, '/fotos/cloud-1_thumb.jpg');
      expect(first.animalEarTag, 'PE-0012');
      expect(first.bodyZone, BodyZone.udder);
      expect(first.result.top.label, 'sarna');
      expect(h.animals.byId(first.animalId!).uuid, 'vaca-1');
      expect(h.photos.saved.keys, unorderedEquals(['cloud-1', 'cloud-2']));
    });

    test(
      'it is offered only when the phone has none of the farmer data',
      () async {
        h.cloud.evaluations.addAll([remote(1), remote(2), remote(3)]);

        expect(await h.service.pendingToRestore(), 3);

        h.evaluations.add(evaluation('local', owner: ownerId));
        expect(await h.service.pendingToRestore(), 0);
      },
    );

    test('without connection nothing is offered', () async {
      h.cloud.offline = true;

      expect(await h.service.pendingToRestore(), 0);
      expect(await h.service.cloudCount(), isNull);
    });

    test(
      'an animal registered here with the same ear tag takes the cloud id',
      () async {
        h.animals.add(1, 'PE-0012', uuid: 'id-local', owner: ownerId);
        h.animalCloud.animals.add(cloudAnimal('id-nube', 'PE-0012'));
        h.cloud.evaluations.add(remote(1, animalUuid: 'id-nube'));

        await h.service.restore();

        expect(h.animals.items, hasLength(1));
        expect(h.animals.byId(1).uuid, 'id-nube');
        expect(h.evaluations.items['cloud-1']!.animalId, 1);
      },
    );
  });

  group('HU13, scenario 2: 200 evaluations', () {
    test('all come back in pages, with the progress up to 200', () async {
      for (var i = 0; i < 200; i++) {
        h.cloud.evaluations.add(remote(i));
      }
      final progress = <int>[];

      final watch = Stopwatch()..start();
      final report = await h.service.restore(
        onProgress: (p) => progress.add(p.done),
      );

      expect(report.restored, 200);
      expect(h.evaluations.items, hasLength(200));
      expect(h.cloud.pages, 4);
      expect(progress.last, 200);
      expect(progress, orderedEquals([...progress]..sort()));
      expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    });
  });

  group('HU13, scenario 3: only the farmer data', () {
    test('everything restored belongs to the signed in farmer', () async {
      h.cloud.evaluations.addAll([remote(1), remote(2)]);

      await h.service.restore();

      expect(
        h.evaluations.items.values.every((e) => e.ownerId == ownerId),
        isTrue,
      );
    });

    test('without a session nothing is downloaded', () async {
      h.sessions.stored = null;
      h.cloud.evaluations.add(remote(1));

      final report = await h.service.restore();

      expect(report.outcome, RestoreOutcome.signedOut);
      expect(h.cloud.downloads, isEmpty);
    });
  });

  group('A cut restore continues where it stopped', () {
    test('the second run downloads only what was missing', () async {
      for (var i = 0; i < 120; i++) {
        h.cloud.evaluations.add(remote(i));
      }
      h.cloud.dropOn.add('cloud-70');

      final first = await h.service.restore();

      expect(first.outcome, RestoreOutcome.offline);
      expect(h.evaluations.items.length, lessThan(120));
      final downloadedBefore = h.cloud.downloads.length;

      final second = await h.service.restore();

      expect(second.outcome, RestoreOutcome.completed);
      expect(h.evaluations.items, hasLength(120));
      expect(
        h.cloud.downloads.length - downloadedBefore,
        120 - downloadedBefore,
      );
      expect(h.cloud.downloads.toSet(), hasLength(120)); // none twice
    });

    test(
      'a photo that is no longer in the cloud is skipped and counted',
      () async {
        h.cloud.evaluations.addAll([remote(1), remote(2)]);
        h.cloud.missingPhotos.add('cloud-2');

        final report = await h.service.restore();

        expect(report.outcome, RestoreOutcome.completed);
        expect(report.restored, 1);
        expect(report.missingPhotos, 1);
        expect(h.evaluations.items.keys, ['cloud-1']);
      },
    );
  });
}
