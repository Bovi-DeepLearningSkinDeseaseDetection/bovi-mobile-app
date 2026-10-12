import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Outlined icon on a soft green circle, as in the design system iconography.
class IconBubble extends StatelessWidget {
  /// Usually an [Icon]; any widget that reads the [IconTheme] works.
  final Widget icon;
  final double size;
  final Color background;
  final Color color;

  const IconBubble({
    super.key,
    required this.icon,
    this.size = 56,
    this.background = AppColors.mint,
    this.color = AppColors.darkGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: IconTheme.merge(
        data: IconThemeData(color: color, size: size * 0.46),
        child: icon,
      ),
    );
  }
}
