import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/status_badge.dart';
import '../../../../domain/model/aggregates/evaluation.dart';
import '../../../../domain/model/value_objects/evaluation_outcome.dart';
import '../../../../infrastructure/catalog/lesion_class_catalog.dart';
import '../../../../../shared/interfaces/ui/formatters/date_formatters.dart';
import '../result/result_texts.dart';

/// Informative card of the history: thumbnail, result, date, status badge
/// and synchronization state (HU11, scenario 1).
class EvaluationCard extends StatelessWidget {
  final Evaluation evaluation;
  final VoidCallback onTap;

  const EvaluationCard({
    super.key,
    required this.evaluation,
    required this.onTap,
  });

  /// Headline of the result, as on the result screen.
  static String titleOf(Evaluation evaluation) =>
      evaluation.outcome == EvaluationOutcome.inconclusive
      ? ResultTexts.inconclusiveTitle
      : LesionClassCatalog.resultTitle(evaluation.result.top.label);

  /// Animal and body zone (HU11, scenario 1), for example
  /// "Arete PE0012 · Lomo", or "Sin animal".
  static String animalText(Evaluation evaluation) {
    final earTag = evaluation.animalEarTag;
    if (earTag == null) return 'Sin animal';
    final zone = evaluation.bodyZone;
    return zone == null ? 'Arete $earTag' : 'Arete $earTag · ${zone.label}';
  }

  static HealthStatus statusOf(EvaluationOutcome outcome) => switch (outcome) {
    EvaluationOutcome.healthy => HealthStatus.healthy,
    EvaluationOutcome.lesion => HealthStatus.lesion,
    EvaluationOutcome.inconclusive => HealthStatus.review,
  };

  @override
  Widget build(BuildContext context) {
    final top = evaluation.result.top;
    final textTheme = TextTheme.of(context);
    final pixels = (72 * MediaQuery.devicePixelRatioOf(context)).round();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(evaluation.thumbnailPath),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  cacheWidth: pixels,
                  errorBuilder: (_, _, _) => const SizedBox.square(
                    dimension: 72,
                    child: ColoredBox(
                      color: AppColors.softGray,
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleOf(evaluation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormatters.dayAndTime(evaluation.createdAt)} · '
                      '${top.percentText}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      animalText(evaluation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: evaluation.animalEarTag == null
                            ? AppColors.secondaryText
                            : AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(status: statusOf(evaluation.outcome)),
                        _SyncLabel(status: evaluation.syncStatus),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncLabel extends StatelessWidget {
  final SyncStatus status;

  const _SyncLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final synced = status == SyncStatus.synced;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
          size: 16,
          color: synced ? AppColors.synchronized : AppColors.secondaryText,
        ),
        const SizedBox(width: 4),
        Text(
          synced ? status.label : 'Pendiente',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
