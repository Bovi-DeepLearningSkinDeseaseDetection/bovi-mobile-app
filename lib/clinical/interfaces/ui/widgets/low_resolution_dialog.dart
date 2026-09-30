import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// What the user chose after being warned about a low-resolution image.
enum LowResolutionChoice { takePhoto, chooseAnother }

/// Warns that a gallery image is below 720p and suggests taking a new photo.
Future<LowResolutionChoice> showLowResolutionDialog(
  BuildContext context,
) async {
  final choice = await showDialog<LowResolutionChoice>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.reviewStatus,
        size: 32,
      ),
      title: const Text('Resolución insuficiente'),
      content: const Text(
        'La imagen no tiene la resolución mínima (720p) para analizarla. '
        'Le sugerimos tomar una nueva foto con la cámara.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(LowResolutionChoice.chooseAnother),
          child: const Text('Elegir otra'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(LowResolutionChoice.takePhoto),
          child: const Text('Tomar foto'),
        ),
      ],
    ),
  );
  return choice ?? LowResolutionChoice.takePhoto;
}
