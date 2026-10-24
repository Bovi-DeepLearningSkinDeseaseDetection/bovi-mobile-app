import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../shared/interfaces/ui/widgets/stethoscope_icon.dart';
import '../../../application/internal/commandservices/detection_pipeline_service.dart';
import '../../../application/internal/commandservices/evaluation_command_service.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../domain/model/value_objects/model_input.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../widgets/quality_issue_dialog.dart';
import 'result_page.dart';

/// What the user decided on the preview screen.
enum PreviewDecision { analyze, retake }

/// Shows the captured or selected image before it is analyzed.
class ImagePreviewPage extends StatefulWidget {
  final CapturedImage image;
  final DetectionPipelineService? pipeline;

  /// Saves each analysis (HU10). Without it, the registered service is used;
  /// if there is none, as in widget tests, nothing is saved.
  final EvaluationCommandService? evaluations;

  const ImagePreviewPage({
    super.key,
    required this.image,
    this.pipeline,
    this.evaluations,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final DetectionPipelineService _pipeline =
      widget.pipeline ?? DetectionPipelineService();
  bool _isAnalyzing = false;

  bool get _fromCamera => widget.image.origin == ImageOrigin.camera;

  String get _retakeLabel => _fromCamera ? 'Repetir' : 'Elegir otra';

  // HU04 and HU05: validate the quality and prepare the image for the model.
  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    try {
      final outcome = await _pipeline.run(widget.image);
      if (!mounted) return;
      switch (outcome) {
        case RejectedByQuality(:final report):
          setState(() => _isAnalyzing = false);
          final choice = await showQualityDialog(
            context,
            report: report,
            retakeLabel: _qualityRetakeLabel,
          );
          if (!mounted) return;
          if (choice == QualityDialogChoice.retake) {
            Navigator.of(context).pop(PreviewDecision.retake);
          }
        case QualityWarning(:final input, :final report):
          setState(() => _isAnalyzing = false);
          final choice = await showQualityDialog(
            context,
            report: report,
            retakeLabel: _qualityRetakeLabel,
          );
          if (!mounted) return;
          switch (choice) {
            case QualityDialogChoice.retake:
              Navigator.of(context).pop(PreviewDecision.retake);
            case QualityDialogChoice.analyzeAnyway:
              await _classify(input);
            case QualityDialogChoice.close:
              break;
          }
        case ReadyForInference(:final input):
          await _classify(input);
      }
    } catch (_) {
      _showError('No se pudo procesar la imagen.');
    }
  }

  String get _qualityRetakeLabel =>
      _fromCamera ? 'Tomar otra foto' : 'Elegir otra';

  // HU06: run the model on the device and show the preliminary result.
  Future<void> _classify(ModelInput input) async {
    setState(() => _isAnalyzing = true);
    try {
      final result = await _pipeline.analyze(input);
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      // HU10: every analysis is saved automatically, inconclusive included.
      final saving = _save(result);
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              ResultPage(image: widget.image, result: result, saving: saving),
        ),
      );
      // The camera deletes its temporary photo after this page closes, so
      // the copy must be finished first.
      await saving;
      if (!mounted) return;
      // Leaving the result goes back to the camera for the next photo.
      Navigator.of(context).pop(PreviewDecision.analyze);
    } catch (error) {
      debugPrint('Inference failed: $error');
      _showError('No se pudo analizar la imagen.');
    }
  }

  /// Returns whether the evaluation was saved.
  Future<bool> _save(InferenceResult result) async {
    final service =
        widget.evaluations ??
        (locator.isRegistered<EvaluationCommandService>()
            ? locator<EvaluationCommandService>()
            : null);
    if (service == null) return false;
    try {
      await service.save(widget.image, result);
      return true;
    } catch (error) {
      debugPrint('Saving the evaluation failed: $error');
      return false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Image.file(
                      File(widget.image.path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.softGray,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.secondaryText,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Revise que la lesión se vea nítida y bien iluminada.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isAnalyzing ? null : _analyze,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const StethoscopeIcon(),
                    label: Text(_isAnalyzing ? 'Analizando…' : 'Analizar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () =>
                              Navigator.of(context).pop(PreviewDecision.retake),
                    icon: Icon(
                      _fromCamera
                          ? Icons.refresh_rounded
                          : Icons.photo_library_outlined,
                    ),
                    label: Text(_retakeLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
