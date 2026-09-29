import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Shows examples of well-framed and poorly-framed photos.
Future<void> showFramingHelp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cómo tomar una buena foto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _ExamplePhoto(
                    asset: 'assets/images/example_correct.jpg',
                    isCorrect: true,
                    description: 'Cerca, centrada y bien iluminada',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ExamplePhoto(
                    asset: 'assets/images/example_incorrect.jpg',
                    isCorrect: false,
                    description: 'Lejos, borrosa o muy oscura',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ExamplePhoto extends StatelessWidget {
  final String asset;
  final bool isCorrect;
  final String description;

  const _ExamplePhoto({
    required this.asset,
    required this.isCorrect,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.softGray,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: isCorrect
                  ? AppColors.healthyStatus
                  : AppColors.lesionStatus,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(description, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}
