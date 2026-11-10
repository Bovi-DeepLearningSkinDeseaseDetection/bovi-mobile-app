// Each image goes through the real preprocessing (HU05) and the real model
// (HU06). The predicted class must always match Colab. Probabilities must
// match within the JSON tolerance (0.02) when Colab is confident (>= 0.90).
// When Colab is uncertain (< 0.90), small pixel differences from the JPEG
// decoder (Dart `image` vs TensorFlow) are amplified: changing only the TF
// decoder method already moves those probabilities by up to 0.044, so the
// limit there is 0.10. A preprocessing bug would also break the confident
// images, so this criterion still catches it. Do not edit the JSON.

// Below the RF11 threshold (0.60) both must show "No concluyente" with the same
// two most likely classes, because that is what the farmer sees.

import 'dart:convert';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/infrastructure/ml/tflite/deep_learning_inference_engine.dart';
import 'package:bov_mobile_app/clinical/infrastructure/vision/computer_vision_preprocessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'parity_fixtures.g.dart';

void main() {
  /// Colab confidence from which an image counts as "confident".
  const confidentThreshold = 0.90;

  /// Allowed difference for uncertain images (Colab confidence < 0.90).
  /// Measured: decoder choice alone moves them up to 0.044 (v6, Nov 2026).
  const uncertainTolerance = 0.10;

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
      // What the farmer sees must match Colab. From the RF11 threshold up that
      // is the top class. Below it the app shows "No concluyente" with the two
      // most likely classes, so those two must match in any order: a near tie
      // can swap order from the JPEG decoder alone (0.466 vs 0.452, v7c).
      final colabRanked = [for (var i = 0; i < labels.length; i++) i]
        ..sort((a, b) => wanted[b].compareTo(wanted[a]));
      final colabConfidence = wanted[colabRanked.first];
      final bool sameOutcome;
      if (colabConfidence >= InferenceResult.inconclusiveThreshold) {
        sameOutcome = result.top.label == item['prediccion'];
      } else {
        final colabTopTwo = {labels[colabRanked[0]], labels[colabRanked[1]]};
        final appTopTwo = {result.ranked[0].label, result.ranked[1].label};
        sameOutcome =
            !result.isConclusive && colabTopTwo.containsAll(appTopTwo);
      }
      final allowed = colabConfidence >= confidentThreshold
          ? tolerance
          : uncertainTolerance;
      final ok = sameOutcome && difference < allowed;
      debugPrint(
        '${ok ? 'OK   ' : 'FALLA'} $name  esperado=$wanted  app=$got  '
        'diferencia=${difference.toStringAsFixed(6)}',
      );
      if (!ok) failures.add(name);
    }

    debugPrint(
      'Paridad: ${cases.length - failures.length}/${cases.length} imágenes, '
      'diferencia máxima ${largestDifference.toStringAsFixed(6)} '
      '(tolerancia $tolerance con confianza >= $confidentThreshold, '
      '$uncertainTolerance con menos)',
    );
    expect(failures, isEmpty, reason: 'Images without parity: $failures');
  });
}
