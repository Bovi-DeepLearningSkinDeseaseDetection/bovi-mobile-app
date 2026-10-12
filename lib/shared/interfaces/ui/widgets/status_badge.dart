import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Status of an evaluated animal, as shown in the badges of the design system.
enum HealthStatus {
  healthy(
    'Saludable',
    Icons.check_circle_rounded,
    AppColors.healthyStatus,
    AppColors.healthySurface,
    AppColors.healthyText,
  ),
  review(
    'Requiere revisión',
    Icons.error_rounded,
    AppColors.reviewStatus,
    AppColors.reviewSurface,
    AppColors.reviewText,
  ),
  lesion(
    'Posible lesión',
    Icons.cancel_rounded,
    AppColors.lesionStatus,
    AppColors.lesionSurface,
    AppColors.lesionText,
  );

  const HealthStatus(
    this.label,
    this.icon,
    this.color,
    this.surface,
    this.textColor,
  );

  final String label;
  final IconData icon;

  /// Color of the icon.
  final Color color;

  /// Background of the badge.
  final Color surface;

  /// Color of the label, darker than [color] so it is readable.
  final Color textColor;
}

/// Pill-shaped badge with an icon and the status label.
class StatusBadge extends StatelessWidget {
  final HealthStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: ShapeDecoration(
        color: status.surface,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 18, color: status.color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: status.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
