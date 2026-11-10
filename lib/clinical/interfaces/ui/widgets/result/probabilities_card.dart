import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/value_objects/inference_result.dart';
import '../../../../infrastructure/catalog/lesion_class_catalog.dart';
import 'result_texts.dart';

/// Card with each class and its probability as text and as a bar.
class ProbabilitiesCard extends StatelessWidget {
  final List<ClassProbability> classes;

  const ProbabilitiesCard({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ResultTexts.probabilitiesTitle,
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
    const textStyle = TextStyle(fontSize: 15, color: AppColors.primaryText);
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
                  style: textStyle,
                ),
              ),
              Text(
                item.percentText,
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
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
