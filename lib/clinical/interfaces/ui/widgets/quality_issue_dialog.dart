import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../../domain/model/value_objects/image_quality.dart';

/// What the user chose in the quality dialog.
enum QualityDialogChoice { retake, analyzeAnyway, close }

/// Explains a quality problem found in the photo (HU04).
///
/// A rejected photo can only be retaken. A doubtful photo can also be
/// analyzed anyway, so users with weaker cameras are not blocked.
Future<QualityDialogChoice> showQualityDialog(
  BuildContext context, {
  required ImageQualityReport report,
  required String retakeLabel,
}) async {
  final rejected = !report.isValid;
  final choice = await showDialog<QualityDialogChoice>(
    context: context,
    builder: (context) => AlertDialog(
      icon: IconBubble(
        icon: Icon(
          rejected ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
        ),
        background: AppColors.reviewSurface,
        color: AppColors.reviewStatus,
      ),
      title: Text(
        rejected ? 'No se puede analizar la foto' : 'La foto podría mejorar',
      ),
      content: Text(report.message ?? '', textAlign: TextAlign.center),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            rejected
                ? QualityDialogChoice.close
                : QualityDialogChoice.analyzeAnyway,
          ),
          child: Text(rejected ? 'Cerrar' : 'Analizar de todos modos'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(QualityDialogChoice.retake),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Text(retakeLabel),
        ),
      ],
    ),
  );
  return choice ?? QualityDialogChoice.close;
}
