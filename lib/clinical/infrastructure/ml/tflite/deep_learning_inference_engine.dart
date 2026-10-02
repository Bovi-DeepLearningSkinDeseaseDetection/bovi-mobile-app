import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../domain/model/value_objects/inference_result.dart';
import '../../../domain/model/value_objects/model_input.dart';
import '../../../domain/services/skin_lesion_classifier.dart';

/// Runs the MobileNetV3 model on the device with TensorFlow Lite (HU06).
///
/// Everything it needs ships inside the app, so it works without internet.
/// The classes and the model version are read from files next to the model:
/// replacing those files is enough to switch to another model.
class DeepLearningInferenceEngine implements SkinLesionClassifier {
  static const modelAsset = 'tensor-flow-package/bovi_modelo_fp16.tflite';
  static const labelsAsset = 'tensor-flow-package/etiquetas.txt';
  static const versionAsset = 'tensor-flow-package/version.txt';

  /// Single instance, so the model is loaded only once.
  static final shared = DeepLearningInferenceEngine();

  Future<_LoadedModel>? _loading;

  /// Reads the labels file: one class per line, blank lines ignored.
  static List<String> parseLabels(String text) => [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  @override
  Future<InferenceResult> classify(ModelInput input) async {
    final model = await _load();
    final stopwatch = Stopwatch()..start();

    // The tensor is sent as raw bytes; the model already knows its shape.
    final bytes = input.data.buffer.asUint8List(
      input.data.offsetInBytes,
      input.data.lengthInBytes,
    );
    final output = [List<double>.filled(model.labels.length, 0)];

    // Runs in a background isolate so the screen does not freeze.
    await model.background.run(bytes, output);

    // Softmax probabilities add up to 1. If they do not, the background run
    // did not hand the output back, so run it directly as a fallback.
    if (_sum(output.first) < 0.5) model.interpreter.run(bytes, output);

    return InferenceResult.fromScores(
      labels: model.labels,
      scores: output.first,
      modelVersion: model.version,
      elapsed: stopwatch.elapsed,
    );
  }

  static double _sum(List<double> values) {
    var total = 0.0;
    for (final value in values) {
      total += value;
    }
    return total;
  }

  Future<_LoadedModel> _load() => _loading ??= _loadOrReset();

  // If loading fails, forget the attempt so the next analysis can retry.
  Future<_LoadedModel> _loadOrReset() async {
    try {
      return await _loadModel();
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  static Future<_LoadedModel> _loadModel() async {
    final labels = parseLabels(await rootBundle.loadString(labelsAsset));
    final version = (await rootBundle.loadString(versionAsset)).trim();
    final interpreter = await Interpreter.fromAsset(modelAsset);

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    if (!_sameShape(inputShape, ModelInput.shape)) {
      throw StateError(
        'The model expects $inputShape but the app sends ${ModelInput.shape}.',
      );
    }
    if (outputShape.length != 2 || outputShape[1] != labels.length) {
      throw StateError(
        'The model returns $outputShape but etiquetas.txt has '
            '${labels.length} classes.',
      );
    }

    final background = await IsolateInterpreter.create(
      address: interpreter.address,
    );
    return _LoadedModel(interpreter, background, labels, version);
  }

  static bool _sameShape(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _LoadedModel {
  final Interpreter interpreter;
  final IsolateInterpreter background;
  final List<String> labels;
  final String version;

  const _LoadedModel(
      this.interpreter,
      this.background,
      this.labels,
      this.version,
      );
}
