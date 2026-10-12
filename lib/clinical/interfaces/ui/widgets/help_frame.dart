import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// Shows examples of well-framed and poorly-framed photos.
Future<void> showFramingHelp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: IconBubble(
                icon: Icon(Icons.photo_camera_outlined),
                size: 56,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cómo tomar una buena foto',
              textAlign: TextAlign.center,
              style: TextTheme.of(context).headlineSmall,
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 24),
            FilledButton(
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
    final color = isCorrect ? AppColors.healthyStatus : AppColors.lesionStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.softGray,
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
