import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/status_badge.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../infrastructure/catalog/lesion_class_catalog.dart';

/// Shows the preliminary result of the analysis (HU07 and HU08).
class ResultPage extends StatelessWidget {
  static const pageTitle = 'Diagnóstico';
  static const sectionTitle = 'Resultado preliminar';
  static const inconclusiveTitle = 'Resultado no concluyente';
  static const inconclusiveAdvice =
      'Repita la foto siguiendo la guía de encuadre o consulte a un médico '
      'veterinario.';
  static const lesionAdvice =
      'Se observan signos compatibles con una posible lesión en la piel. '
      'Te recomendamos consultar con un profesional veterinario.';
  static const healthyAdvice = 'No se observan signos de lesión en la piel.';
  static const disclaimerText =
      'Este resultado es preliminar y no reemplaza el diagnóstico de un '
      'médico veterinario.';
  static const saveLabel = 'Guardar resultado';
  static const retakeLabel = 'Nuevo escaneo';

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
      appBar: AppBar(title: const Text(pageTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Photo(path: image.path),
                    const SizedBox(height: 20),
                    _Verdict(result: result),
                    const SizedBox(height: 20),
                    _Probabilities(classes: classes),
                    const SizedBox(height: 16),
                    const _Disclaimer(),
                    const SizedBox(height: 12),
                    Text(
                      'Modelo ${result.modelVersion} · '
                      '${result.elapsed.inMilliseconds} ms · '
                      'Origen: ${image.origin.label}',
                      style: TextTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The evaluations are saved from HU10 on.
                  FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Guardar resultados estará disponible '
                            'próximamente.',
                          ),
                        ),
                      ),
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text(saveLabel),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text(retakeLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The analyzed photo, with rounded corners.
class _Photo extends StatelessWidget {
  final String path;

  const _Photo({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 210,
        child: Image.file(
          File(path),
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
    );
  }
}

/// Headline of the result: healthy skin, signs of a disease or inconclusive.
class _Verdict extends StatelessWidget {
  final InferenceResult result;

  const _Verdict({required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final top = result.top;
    final conclusive = result.isConclusive;
    final healthy = LesionClassCatalog.isHealthy(top.label);

    final HealthStatus status;
    final String title;
    final Color titleColor;
    if (!conclusive) {
      status = HealthStatus.review;
      title = ResultPage.inconclusiveTitle;
      // The amber color has too little contrast for text; use the dark one.
      titleColor = AppColors.primaryText;
    } else if (healthy) {
      status = HealthStatus.healthy;
      title = LesionClassCatalog.resultTitle(top.label);
      titleColor = AppColors.darkGreen;
    } else {
      status = HealthStatus.lesion;
      title = LesionClassCatalog.resultTitle(top.label);
      titleColor = AppColors.lesionText;
    }

    final bodyStyle = textTheme.bodyMedium?.copyWith(color: AppColors.bodyText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ResultPage.sectionTitle, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        StatusBadge(status: status),
        const SizedBox(height: 14),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(color: titleColor),
        ),
        const SizedBox(height: 4),
        Text(
          conclusive
              ? 'Confianza: ${top.percentText}'
              : ResultPage.inconclusiveAdvice,
          style: conclusive
              ? textTheme.titleMedium?.copyWith(color: AppColors.bodyText)
              : bodyStyle,
        ),
        if (conclusive) ...[
          const SizedBox(height: 8),
          Text(
            healthy ? ResultPage.healthyAdvice : ResultPage.lesionAdvice,
            style: bodyStyle,
          ),
        ],
      ],
    );
  }
}

/// Card with each class and its probability as text and as a bar.
class _Probabilities extends StatelessWidget {
  final List<ClassProbability> classes;

  const _Probabilities({required this.classes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Probabilidad por clase',
              style: TextTheme.of(context).titleSmall,
            ),
            const SizedBox(height: 12),
            for (final item in classes) _ProbabilityRow(item: item),
          ],
        ),
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final ClassProbability item;

  const _ProbabilityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LesionClassCatalog.displayName(item.label),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Text(
                item.percentText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: item.probability.clamp(0.0, 1.0).toDouble(),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mint),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.darkGreen,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              ResultPage.disclaimerText,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
