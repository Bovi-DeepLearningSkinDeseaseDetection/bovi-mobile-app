import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../application/internal/commandservices/detection_pipeline_service.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../widgets/quality_issue_dialog.dart';

/// What the user decided on the preview screen.
enum PreviewDecision { analyze, retake }

/// Shows the captured or selected image before it is analyzed.
class ImagePreviewPage extends StatefulWidget {
  final CapturedImage image;
  final DetectionPipelineService? pipeline;

  const ImagePreviewPage({super.key, required this.image, this.pipeline});

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
          final retake = await showQualityIssueDialog(
            context,
            report: report,
            retakeLabel: _fromCamera ? 'Tomar otra foto' : 'Elegir otra',
          );
          if (retake && mounted) {
            Navigator.of(context).pop(PreviewDecision.retake);
          }
        case ReadyForInference():
          // HU06 will run the model here and open the result screen.
          Navigator.of(context).pop(PreviewDecision.analyze);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo procesar la imagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: Column(
        children: [
          Expanded(
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
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
                        : const Icon(Icons.search),
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
                          ? Icons.refresh
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
