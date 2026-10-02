import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../infrastructure/catalog/lesion_class_catalog.dart';

/// Shows the preliminary result of the analysis (HU07 and HU08).
class ResultPage extends StatelessWidget {
  static const inconclusiveTitle = 'Resultado no concluyente';
  static const inconclusiveAdvice =
      'Repita la foto siguiendo la guía de encuadre o consulte a un médico '
      'veterinario.';
  static const disclaimerText =
      'Este resultado es preliminar y no reemplaza el diagnóstico de un '
      'médico veterinario.';
  static const retakeLabel = 'Tomar otra foto';

  final CapturedImage image;
  final InferenceResult result;

  const ResultPage({super.key, required this.image, required this.result});

  @override
  Widget build(BuildContext context) {
    // HU08: an inconclusive result shows only the two most probable classes.
    final classes = result.isConclusive
        ? result.ranked
        : result.ranked.take(2).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado preliminar')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 220,
                        child: Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: AppColors.softGray,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.secondaryText,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Verdict(result: result),
                    const SizedBox(height: 16),
                    for (final item in classes) _ProbabilityRow(item: item),
                    const SizedBox(height: 8),
                    const _Disclaimer(),
                    const SizedBox(height: 12),
                    Text(
                      'Modelo ${result.modelVersion} · '
                      '${result.elapsed.inMilliseconds} ms · '
                      'Origen: ${image.origin.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text(retakeLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Headline of the result: healthy skin, signs of a disease or inconclusive.
class _Verdict extends StatelessWidget {
  final InferenceResult result;

  const _Verdict({required this.result});

  @override
  Widget build(BuildContext context) {
    final top = result.top;
    final conclusive = result.isConclusive;
    final healthy = LesionClassCatalog.isHealthy(top.label);

    final String title;
    final IconData icon;
    final Color iconColor;
    final Color titleColor;
    if (!conclusive) {
      title = ResultPage.inconclusiveTitle;
      icon = Icons.help_outline;
      iconColor = AppColors.reviewStatus;
      // The amber color has too little contrast for text; use the dark one.
      titleColor = AppColors.primaryText;
    } else if (healthy) {
      title = LesionClassCatalog.resultTitle(top.label);
      icon = Icons.check_circle_outline;
      iconColor = AppColors.healthyStatus;
      titleColor = AppColors.healthyStatus;
    } else {
      title = LesionClassCatalog.resultTitle(top.label);
      icon = Icons.report_problem_outlined;
      iconColor = AppColors.lesionStatus;
      titleColor = AppColors.lesionStatus;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              conclusive
                  ? 'Confianza: ${top.percentText}'
                  : ResultPage.inconclusiveAdvice,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One class with its probability as text and as a bar.
class _ProbabilityRow extends StatelessWidget {
  final ClassProbability item;

  const _ProbabilityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LesionClassCatalog.displayName(item.label),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Text(
                item.percentText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.probability.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.softGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notice required on every result (HU09, scenario 2).
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutralChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.secondaryText, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              ResultPage.disclaimerText,
              style: TextStyle(fontSize: 14, color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
