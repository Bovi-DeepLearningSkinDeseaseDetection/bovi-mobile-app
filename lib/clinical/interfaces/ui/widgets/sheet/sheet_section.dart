import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// Titled card of a disease sheet with a list of short points.
class SheetSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> points;

  /// Optional paragraph shown before the points.
  final String? text;

  const SheetSection({
    super.key,
    required this.icon,
    required this.title,
    this.points = const [],
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final bodyStyle = textTheme.bodyMedium?.copyWith(color: AppColors.bodyText);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBubble(icon: Icon(icon), size: 36),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: textTheme.titleMedium)),
              ],
            ),
            if (text != null) ...[
              const SizedBox(height: 10),
              Text(text!, style: bodyStyle),
            ],
            for (final point in points)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(point, style: bodyStyle)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
