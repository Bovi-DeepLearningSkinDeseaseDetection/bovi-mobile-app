import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/status_badge.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/clinical_code.dart';
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
  static const retakeLabel = 'Nuevo escaneo';
  static const savingText = 'Guardando en el historial…';
  static const savedText = 'Guardado en el historial';
  static const notSavedText = 'No se pudo guardar en el historial';

  final CapturedImage image;
  final InferenceResult result;

  /// Automatic save of a new analysis (HU10); null when nothing is saved.
  final Future<bool>? saving;

  /// Date of a saved evaluation. When given, the page shows an evaluation of
  /// the history: with its date and without the scan action.
  final DateTime? evaluatedAt;

  /// Standard codes of the result (HU07): MeSH and NCBI Taxonomy.
  final List<ClinicalCode> codes;

  const ResultPage({
    super.key,
    required this.image,
    required this.result,
    this.saving,
    this.evaluatedAt,
    this.codes = const [],
  });

  @override
  Widget build(BuildContext context) {
    // HU08: an inconclusive result shows only the two most probable classes.
    final classes = result.isConclusive
        ? result.ranked
        : result.ranked.take(2).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(evaluatedAt == null ? pageTitle : 'Evaluación'),
      ),
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
                    if (evaluatedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        formatEvaluationDate(evaluatedAt!),
                        style: TextTheme.of(context).bodySmall,
                      ),
                    ],
                    if (saving != null) ...[
                      const SizedBox(height: 12),
                      _SaveStatus(saving: saving!),
                    ],
                    const SizedBox(height: 20),
                    _Verdict(result: result),
                    if (codes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ClinicalCodes(codes: codes),
                    ],
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
            if (evaluatedAt == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text(retakeLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Date and time of an evaluation, for example "24/10/2026 · 10:35".
String formatEvaluationDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} · '
      '${two(date.hour)}:${two(date.minute)}';
}

/// Progress of the automatic save of a new analysis.
class _SaveStatus extends StatelessWidget {
  final Future<bool> saving;

  const _SaveStatus({required this.saving});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: saving,
      builder: (context, snapshot) {
        final Widget icon;
        final String text;
        final Color color;
        if (snapshot.connectionState != ConnectionState.done) {
          icon = const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
          text = ResultPage.savingText;
          color = AppColors.secondaryText;
        } else if (snapshot.data ?? false) {
          icon = const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.healthyStatus,
          );
          text = ResultPage.savedText;
          color = AppColors.healthyText;
        } else {
          icon = const Icon(
            Icons.error_rounded,
            size: 18,
            color: AppColors.reviewStatus,
          );
          text = ResultPage.notSavedText;
          color = AppColors.reviewText;
        }
        return Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        );
      },
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

/// Standard codes of the detected disease and its causal agent (HU07).
class _ClinicalCodes extends StatelessWidget {
  static const title = 'Codificación clínica';

  final List<ClinicalCode> codes;

  const _ClinicalCodes({required this.codes});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleSmall),
            const SizedBox(height: 10),
            for (final code in codes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: ShapeDecoration(
                        color: AppColors.mint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${code.systemName} ${code.code}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          code.display,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.bodyText,
                            // Organisms are written in italics.
                            fontStyle: code.isOrganism
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
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
