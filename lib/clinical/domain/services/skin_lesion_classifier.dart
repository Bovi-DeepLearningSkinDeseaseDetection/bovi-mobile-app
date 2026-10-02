import '../model/value_objects/inference_result.dart';
import '../model/value_objects/model_input.dart';

/// Classifies a preprocessed photo. The app only knows this contract, so the
/// model engine can be replaced or faked in tests.
abstract interface class SkinLesionClassifier {
  Future<InferenceResult> classify(ModelInput input);
}
