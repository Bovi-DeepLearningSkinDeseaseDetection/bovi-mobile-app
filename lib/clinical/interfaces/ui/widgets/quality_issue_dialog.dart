import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/value_objects/image_quality.dart';

/// Explains why the photo was not analyzed (HU04).
///
/// Returns true when the user wants to take or choose another photo.
Future<bool> showQualityIssueDialog(
  BuildContext context, {
  required ImageQualityReport report,
  required String retakeLabel,
}) async {
  final retake = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.reviewStatus,
        size: 32,
      ),
      title: const Text('No se puede analizar la foto'),
      content: Text(report.message ?? ''),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cerrar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(retakeLabel),
        ),
      ],
    ),
  );
  return retake ?? false;
}
