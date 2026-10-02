import 'package:flutter/foundation.dart';

import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/image_quality.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../domain/model/value_objects/model_input.dart';
import '../../../domain/services/skin_lesion_classifier.dart';
import '../../../infrastructure/ml/tflite/deep_learning_inference_engine.dart';
import '../../../infrastructure/vision/computer_vision_preprocessor.dart';

/// Result of running the detection pipeline on a photo.
sealed class DetectionOutcome {
  const DetectionOutcome();
}

/// The photo failed the quality check and was not analyzed (HU04).
class RejectedByQuality extends DetectionOutcome {
  final ImageQualityReport report;

  const RejectedByQuality(this.report);
}

/// The photo is doubtful but can be analyzed if the user confirms (HU04).
class QualityWarning extends DetectionOutcome {
  final ModelInput input;
  final ImageQualityReport report;

  const QualityWarning(this.input, this.report);
}

/// The photo passed the quality check and is ready for the model (HU05).
class ReadyForInference extends DetectionOutcome {
  final ModelInput input;
  final ImageQualityReport report;

  const ReadyForInference(this.input, this.report);
}

/// Runs the detection flow triggered by "Analizar": quality check and
/// preprocessing with [run], then the model with [analyze] (HU06).
class DetectionPipelineService {
  final ComputerVisionPreprocessor _preprocessor;
  final SkinLesionClassifier _classifier;

  DetectionPipelineService({
    ComputerVisionPreprocessor? preprocessor,
    SkinLesionClassifier? classifier,
  }) : _preprocessor = preprocessor ?? const ComputerVisionPreprocessor(),
       _classifier = classifier ?? DeepLearningInferenceEngine.shared;

  Future<DetectionOutcome> run(CapturedImage image) async {
    final result = await _preprocessor.process(image.path);
    debugPrint(
      'Preprocessing took ${result.elapsed.inMilliseconds} ms '
      '(${image.width}x${image.height}): ${result.quality}',
    );
    if (!result.quality.isValid) return RejectedByQuality(result.quality);
    if (result.quality.hasWarnings) {
      return QualityWarning(result.input, result.quality);
    }
    return ReadyForInference(result.input, result.quality);
  }

  /// Classifies a photo that already passed [run]. A rejected photo never
  /// reaches this point, because it has no [ModelInput] to pass.
  Future<InferenceResult> analyze(ModelInput input) async {
    final result = await _classifier.classify(input);
    final scores = result.probabilities
        .map((p) => '${p.label}=${p.probability.toStringAsFixed(4)}')
        .join(', ');
    debugPrint(
      'Inference took ${result.elapsed.inMilliseconds} ms '
      '(model ${result.modelVersion}): $scores',
    );
    return result;
  }
}
