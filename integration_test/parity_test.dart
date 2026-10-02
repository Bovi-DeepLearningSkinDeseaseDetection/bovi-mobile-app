// Parity test: the phone must give the same probabilities as Colab.
//
// Each image goes through the real preprocessing (HU05) and the real model
// (HU06). If this fails, the app is not feeding the model the same pixels it
// was trained with: fix the preprocessing, never the tolerance or the JSON.
//
// Run with the phone connected:
//   flutter test integration_test/parity_test.dart -d <device id>
import 'dart:convert';

import 'package:bov_mobile_app/clinical/infrastructure/ml/tflite/deep_learning_inference_engine.dart';
import 'package:bov_mobile_app/clinical/infrastructure/vision/computer_vision_preprocessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'parity_fixtures.g.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the app reproduces the Colab probabilities', (tester) async {
    final expected = jsonDecode(parityExpectedJson) as Map<String, dynamic>;
    final labels = (expected['clases'] as List).cast<String>();
    final tolerance = (expected['tolerancia'] as num).toDouble();
    final cases = (expected['casos'] as List).cast<Map<String, dynamic>>();

    final engine = DeepLearningInferenceEngine.shared;
    final failures = <String>[];
    var largestDifference = 0.0;

    for (final item in cases) {
      final name = item['archivo'] as String;
      final wanted = [
        for (final value in item['probabilidades'] as List)
          (value as num).toDouble(),
      ];

      final bytes = base64Decode(parityImages[name]!);
      final prepared = ComputerVisionPreprocessor.processBytes(bytes);
      final result = await engine.classify(prepared.input);

      // The app must read the classes in the same order as Colab.
      expect([for (final p in result.probabilities) p.label], labels);

      var difference = 0.0;
      for (var i = 0; i < wanted.length; i++) {
        final gap = (result.probabilities[i].probability - wanted[i]).abs();
        if (gap > difference) difference = gap;
      }
      if (difference > largestDifference) largestDifference = difference;

      final got = [
        for (final p in result.probabilities) p.probability.toStringAsFixed(6),
      ];
      final sameClass = result.top.label == item['prediccion'];
      final ok = sameClass && difference < tolerance;
      debugPrint(
        '${ok ? 'OK   ' : 'FALLA'} $name  esperado=$wanted  app=$got  '
        'diferencia=${difference.toStringAsFixed(6)}',
      );
      if (!ok) failures.add(name);
    }

    debugPrint(
      'Paridad: ${cases.length - failures.length}/${cases.length} imágenes, '
      'diferencia máxima ${largestDifference.toStringAsFixed(6)} '
      '(tolerancia $tolerance)',
    );
    expect(failures, isEmpty, reason: 'Images without parity: $failures');
  });
}
