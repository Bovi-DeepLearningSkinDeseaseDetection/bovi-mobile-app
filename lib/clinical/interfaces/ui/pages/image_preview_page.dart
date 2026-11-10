import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../application/internal/commandservices/detection_pipeline_service.dart';
import '../../../application/internal/commandservices/evaluation_command_service.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/model_input.dart';
import '../viewmodels/detection_pipeline_view_model.dart';
import '../widgets/preview/preview_actions.dart';
import '../widgets/quality_issue_dialog.dart';
import 'result_page.dart';

/// What the user decided on the preview screen.
enum PreviewDecision { analyze, retake }

/// Shows the captured or selected image before it is analyzed. The pipeline
/// runs in [DetectionPipelineViewModel]; this page shows its dialogs and
/// the result.
class ImagePreviewPage extends StatelessWidget {
  final CapturedImage image;
  final DetectionPipelineService? pipeline;

  /// Saves each analysis (HU10). Without it, the registered service is used.
  final EvaluationCommandService? evaluations;

  const ImagePreviewPage({
    super.key,
    required this.image,
    this.pipeline,
    this.evaluations,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetectionPipelineViewModel(
        image,
        pipeline: pipeline,
        evaluations: evaluations,
      ),
      child: const _PreviewView(),
    );
  }
}

class _PreviewView extends StatefulWidget {
  const _PreviewView();

  @override
  State<_PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<_PreviewView> {
  DetectionPipelineViewModel get _model =>
      context.read<DetectionPipelineViewModel>();

  String get _qualityRetakeLabel =>
      _model.fromCamera ? 'Tomar otra foto' : 'Elegir otra';

  // HU04: a rejected photo can only be retaken; a doubtful one can also be
  // analyzed anyway.
  Future<void> _analyze() async {
    try {
      final outcome = await _model.checkQuality();
      if (!mounted) return;
      switch (outcome) {
        case RejectedByQuality(:final report):
          final choice = await showQualityDialog(
            context,
            report: report,
            retakeLabel: _qualityRetakeLabel,
          );
          if (choice == QualityDialogChoice.retake) _leave(retake: true);
        case QualityWarning(:final input, :final report):
          final choice = await showQualityDialog(
            context,
            report: report,
            retakeLabel: _qualityRetakeLabel,
          );
          switch (choice) {
            case QualityDialogChoice.retake:
              _leave(retake: true);
            case QualityDialogChoice.analyzeAnyway:
              await _showResult(input);
            case QualityDialogChoice.close:
              break;
          }
        case ReadyForInference(:final input):
          await _showResult(input);
      }
    } catch (_) {
      _showError('No se pudo procesar la imagen.');
    }
  }

  // HU06 and HU07: the result, while it is saved in the background (HU10).
  Future<void> _showResult(ModelInput input) async {
    final model = _model;
    final Analysis analysis;
    try {
      analysis = await model.classify(input);
    } catch (error) {
      debugPrint('Inference failed: $error');
      _showError('No se pudo analizar la imagen.');
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ResultPage(
          image: model.image,
          result: analysis.result,
          saving: analysis.saving,
          codes: analysis.codes,
          sheet: analysis.sheet,
        ),
      ),
    );
    // The camera deletes its temporary photo after this page closes, so
    // the copy must be finished first.
    await analysis.saving;
    // Leaving the result goes back to the camera for the next photo.
    _leave(retake: false);
  }

  void _leave({required bool retake}) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(retake ? PreviewDecision.retake : PreviewDecision.analyze);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DetectionPipelineViewModel>();
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
                      File(model.image.path),
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
          PreviewActions(
            isAnalyzing: model.isAnalyzing,
            fromCamera: model.fromCamera,
            onAnalyze: _analyze,
            onRetake: () => _leave(retake: true),
          ),
        ],
      ),
    );
  }
}
