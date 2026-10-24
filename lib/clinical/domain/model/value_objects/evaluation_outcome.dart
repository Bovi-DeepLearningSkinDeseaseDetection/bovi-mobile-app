import '../../../infrastructure/catalog/lesion_class_catalog.dart';
import 'inference_result.dart';

/// Kind of preliminary result of an evaluation.
enum EvaluationOutcome {
  healthy,
  lesion,
  inconclusive;

  factory EvaluationOutcome.of(InferenceResult result) {
    if (!result.isConclusive) return EvaluationOutcome.inconclusive;
    return LesionClassCatalog.isHealthy(result.top.label)
        ? EvaluationOutcome.healthy
        : EvaluationOutcome.lesion;
  }
}
