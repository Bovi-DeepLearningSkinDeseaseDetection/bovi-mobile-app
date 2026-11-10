import 'dart:io';

import 'package:bov_mobile_app/clinical/domain/model/queries/evaluation_filter.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/evaluation_outcome.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/infrastructure/persistence/isar/entities/evaluation_entity.dart';
import 'package:bov_mobile_app/clinical/infrastructure/persistence/isar/repositories/isar_evaluation_repository.dart';
import 'package:bov_mobile_app/clinical/infrastructure/storage/evaluation_image_store.dart';
import 'package:bov_mobile_app/livestock/infrastructure/persistence/isar/entities/animal_entity.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';

/// HU11, scenario 5, and RNF11: with 1 000 saved evaluations, a filtered
/// history loads in less than 1 s. Run it on the phone:
///   flutter test integration_test/history_performance_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Isar isar;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('bovi_perf');
    isar = await Isar.open(
      [EvaluationEntitySchema, AnimalEntitySchema],
      directory: directory.path,
      name: 'perf',
    );
    const labels = ['piel_sana', 'dermatofitosis', 'papilomatosis', 'sarna'];
    final start = DateTime(2026, 1, 1);
    await isar.writeTxn(() async {
      for (var i = 0; i < 1000; i++) {
        final label = labels[i % labels.length];
        await isar.evaluations.put(
          EvaluationEntity()
            ..uuid = 'perf-$i'
            ..createdAt = start.add(Duration(hours: i * 7))
            ..updatedAt = start
            ..imageFile = 'perf-$i.jpg'
            ..thumbnailFile = 'perf-${i}_thumb.jpg'
            ..origin = ImageOrigin.camera
            ..outcome = i % 10 == 0
                ? EvaluationOutcome.inconclusive
                : label == 'piel_sana'
                ? EvaluationOutcome.healthy
                : EvaluationOutcome.lesion
            ..topLabel = label
            ..confidence = 0.9
            ..probabilities = [
              for (final l in labels)
                ClassScoreEmbedded()
                  ..label = l
                  ..probability = l == label ? 0.9 : 0.025,
            ]
            ..modelVersion = 'perf'
            ..inferenceMs = 100
            ..animalId = i % 50
            ..animalEarTag = 'A${i % 50}'
            ..syncStatus = i.isEven ? SyncStatus.pending : SyncStatus.synced,
        );
      }
    });
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  testWidgets('1 000 evaluations are filtered in less than 1 s', (_) async {
    final repository = IsarEvaluationRepository(isar, EvaluationImageStore());
    final filters = {
      'all': EvaluationFilter.none,
      'disease': const EvaluationFilter(label: 'sarna'),
      'animal': const EvaluationFilter(animalId: 7),
      'dates': EvaluationFilter(
        from: DateTime(2026, 2, 1),
        to: DateTime(2026, 4, 30),
      ),
      'all filters': EvaluationFilter(
        label: 'dermatofitosis',
        animalId: 3,
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 12, 31),
        syncStatus: SyncStatus.pending,
      ),
    };
    for (final entry in filters.entries) {
      final stopwatch = Stopwatch()..start();
      final evaluations = await repository.watch(entry.value).first;
      stopwatch.stop();
      debugPrint(
        '${entry.key}: ${evaluations.length} results in '
        '${stopwatch.elapsedMilliseconds} ms',
      );
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
      for (var i = 1; i < evaluations.length; i++) {
        expect(
          evaluations[i - 1].createdAt.isAfter(evaluations[i].createdAt),
          isTrue,
          reason: 'newest first',
        );
      }
      expect(evaluations.every(entry.value.matches), isTrue);
    }
  });
}
