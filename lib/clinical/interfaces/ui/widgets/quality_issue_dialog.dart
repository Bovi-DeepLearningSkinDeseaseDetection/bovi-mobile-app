import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
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
      icon: Icon(
        rejected ? Icons.warning_amber_rounded : Icons.info_outline,
        color: AppColors.reviewStatus,
        size: 32,
      ),
      title: Text(
        rejected ? 'No se puede analizar la foto' : 'La foto podría mejorar',
      ),
      content: Text(report.message ?? ''),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            rejected
                ? QualityDialogChoice.close
                : QualityDialogChoice.analyzeAnyway,
          ),
          child: Text(rejected ? 'Cerrar' : 'Analizar de todos modos'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(QualityDialogChoice.retake),
          child: Text(retakeLabel),
        ),
      ],
    ),
  );
  return choice ?? QualityDialogChoice.close;
}
