import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/infrastructure/catalog/lesion_class_catalog.dart';
import 'package:bov_mobile_app/clinical/infrastructure/ml/tflite/deep_learning_inference_engine.dart';
import 'package:flutter_test/flutter_test.dart';

InferenceResult _result(List<String> labels, List<double> scores) =>
    InferenceResult.fromScores(
      labels: labels,
      scores: scores,
      modelVersion: 'test',
      elapsed: Duration.zero,
    );

void main() {
  group('InferenceResult (HU06)', () {
    test('keeps the probabilities in the order of the labels file', () {
      final result = _result(['dermatofitosis', 'piel_sana'], [0.2, 0.8]);

      expect(result.probabilities.map((p) => p.label), [
        'dermatofitosis',
        'piel_sana',
      ]);
      expect(result.top.label, 'piel_sana');
      expect(result.top.percentText, '80 %');
    });

    // The final model has 5 classes; nothing in the code fixes the number.
    test('works with any number of classes', () {
      final result = _result(
        ['sana', 'dermatofitosis', 'papilomatosis', 'sarna', 'miasis'],
        [0.05, 0.1, 0.7, 0.1, 0.05],
      );

      expect(result.probabilities, hasLength(5));
      expect(result.ranked.first.label, 'papilomatosis');
      final total = result.probabilities.fold<double>(
        0,
        (sum, p) => sum + p.probability,
      );
      expect(total, closeTo(1, 0.01));
    });

    test('rejects a different number of scores and labels', () {
      expect(() => _result(['a', 'b'], [1]), throwsArgumentError);
    });

    // RF11, HU08: below 60 % the result is inconclusive.
    test('is conclusive from 60 % confidence', () {
      expect(_result(['a', 'b'], [0.6, 0.4]).isConclusive, isTrue);
      expect(_result(['a', 'b'], [0.59, 0.41]).isConclusive, isFalse);
    });
  });

  test('the labels file ignores blank lines and spaces', () {
    expect(
      DeepLearningInferenceEngine.parseLabels(
        'dermatofitosis\r\n piel_sana \n\n',
      ),
      ['dermatofitosis', 'piel_sana'],
    );
  });

  group('LesionClassCatalog', () {
    test('names the healthy class and the findings', () {
      expect(LesionClassCatalog.resultTitle('piel_sana'), 'Piel sana');
      expect(
        LesionClassCatalog.resultTitle('dermatofitosis'),
        'Indicios de dermatofitosis',
      );
      expect(LesionClassCatalog.isHealthy('dermatofitosis'), isFalse);
    });

    test('shows an unknown class using its label', () {
      expect(LesionClassCatalog.displayName('otra_clase'), 'Otra clase');
    });
  });
}
