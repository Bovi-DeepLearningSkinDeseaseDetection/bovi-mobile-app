import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/aggregates/evaluation.dart';
import 'result_texts.dart';

/// Progress of the automatic save of a new analysis (HU10).
class SaveStatus extends StatelessWidget {
  final Future<Evaluation?> saving;

  const SaveStatus({super.key, required this.saving});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Evaluation?>(
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
          text = ResultTexts.savingText;
          color = AppColors.secondaryText;
        } else if (snapshot.data != null) {
          icon = const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.healthyStatus,
          );
          text = ResultTexts.savedText;
          color = AppColors.healthyText;
        } else {
          icon = const Icon(
            Icons.error_rounded,
            size: 18,
            color: AppColors.reviewStatus,
          );
          text = ResultTexts.notSavedText;
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
