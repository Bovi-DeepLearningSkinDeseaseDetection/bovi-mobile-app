import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// HU11, scenario 4: no evaluations yet, with a button to make the first.
class EmptyHistory extends StatelessWidget {
  static const title = 'Aún no tiene evaluaciones';
  static const message =
      'Los análisis que realice se guardan aquí automáticamente, '
      'aunque no tenga internet.';

  final VoidCallback onScan;

  const EmptyHistory({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
      children: [
        const Center(
          child: IconBubble(icon: Icon(Icons.article_outlined), size: 96),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.bodyText),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.photo_camera_rounded),
          label: const Text('Escanear ahora'),
        ),
      ],
    );
  }
}
