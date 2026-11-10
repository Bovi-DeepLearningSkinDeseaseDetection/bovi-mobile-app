import 'package:flutter/foundation.dart';

import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../application/internal/commandservices/detection_pipeline_service.dart';
import '../../../application/internal/commandservices/evaluation_command_service.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/clinical_code.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../domain/model/value_objects/model_input.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../../../infrastructure/catalog/clinical_code_catalog.dart';

/// Result of the model for the preview, ready to be shown (HU06, HU07).
class Analysis {
  final InferenceResult result;

  /// Standard codes of the result (HU07).
  final List<ClinicalCode> codes;

  /// Automatic save (HU10): the saved evaluation, or null when it failed.
  final Future<Evaluation?> saving;

  const Analysis({
    required this.result,
    required this.codes,
    required this.saving,
  });
}

/// Runs the detection pipeline on one image: quality and preprocessing
/// (HU04, HU05), the model (HU06), its codes (HU07) and the automatic save
/// (HU10). The preview page only shows the dialogs and the result.
class DetectionPipelineViewModel extends ChangeNotifier {
  final CapturedImage image;
  final DetectionPipelineService _pipeline;
  final EvaluationCommandService? _evaluations;
  final ClinicalCodeCatalog? _codes;

  bool _isAnalyzing = false;
  bool _disposed = false;

  /// Without [evaluations] or [codes], the registered ones are used; when
  /// there are none, as in widget tests, nothing is saved or coded.
  DetectionPipelineViewModel(
    this.image, {
    DetectionPipelineService? pipeline,
    EvaluationCommandService? evaluations,
    ClinicalCodeCatalog? codes,
  }) : _pipeline = pipeline ?? DetectionPipelineService(),
       _evaluations = evaluations ?? _registered<EvaluationCommandService>(),
       _codes = codes ?? _registered<ClinicalCodeCatalog>();

  static T? _registered<T extends Object>() =>
      locator.isRegistered<T>() ? locator<T>() : null;

  bool get isAnalyzing => _isAnalyzing;
  bool get fromCamera => image.origin == ImageOrigin.camera;

  /// HU04 and HU05: validates the quality and prepares the model input.
  Future<DetectionOutcome> checkQuality() =>
      _whileAnalyzing(() => _pipeline.run(image));

  /// HU06: runs the model and starts saving the evaluation right away, so
  /// the result shows without waiting for the save.
  Future<Analysis> classify(ModelInput input) => _whileAnalyzing(() async {
    final result = await _pipeline.analyze(input);
    return Analysis(
      result: result,
      codes: _codes?.codesFor(result) ?? const [],
      saving: _save(result),
    );
  });

  Future<Evaluation?> _save(InferenceResult result) async {
    final evaluations = _evaluations;
    if (evaluations == null) return null;
    try {
      return await evaluations.save(image, result);
    } catch (error) {
      debugPrint('Saving the evaluation failed: $error');
      return null;
    }
  }

  Future<T> _whileAnalyzing<T>(Future<T> Function() action) async {
    _setAnalyzing(true);
    try {
      return await action();
    } finally {
      _setAnalyzing(false);
    }
  }

  void _setAnalyzing(bool value) {
    _isAnalyzing = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
