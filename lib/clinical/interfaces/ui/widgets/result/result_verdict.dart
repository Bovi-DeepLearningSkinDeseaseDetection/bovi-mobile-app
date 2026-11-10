import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/status_badge.dart';
import '../../../../domain/model/value_objects/inference_result.dart';
import '../../../../infrastructure/catalog/lesion_class_catalog.dart';
import 'result_texts.dart';

/// Headline of the result: healthy skin, signs of a disease or inconclusive
/// (HU07, HU08).
class ResultVerdict extends StatelessWidget {
  final InferenceResult result;

  /// Opens the information sheet of the disease (HU09); null hides it.
  final VoidCallback? onMore;

  const ResultVerdict({super.key, required this.result, this.onMore});

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
      title = ResultTexts.inconclusiveTitle;
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
        Text(ResultTexts.sectionTitle, style: textTheme.titleMedium),
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
              : ResultTexts.inconclusiveAdvice,
          style: conclusive
              ? textTheme.titleMedium?.copyWith(color: AppColors.bodyText)
              : bodyStyle,
        ),
        if (conclusive) ...[
          const SizedBox(height: 8),
          Text(
            healthy ? ResultTexts.healthyAdvice : ResultTexts.lesionAdvice,
            style: bodyStyle,
          ),
        ],
        if (onMore != null) ...[
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onMore,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text(ResultTexts.moreLabel),
          ),
        ],
      ],
    );
  }
}
