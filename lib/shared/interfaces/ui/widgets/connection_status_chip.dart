import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Header chip that shows whether the device is online.
class ConnectionStatusChip extends StatelessWidget {
  final bool isOnline;

  const ConnectionStatusChip({super.key, required this.isOnline});

  static const onlineText = 'En línea';
  static const offlineText = 'Sin conexión';

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: isOnline ? AppColors.healthySurface : AppColors.neutralChip,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.synchronized : AppColors.offline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? onlineText : offlineText,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isOnline ? AppColors.healthyText : AppColors.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
