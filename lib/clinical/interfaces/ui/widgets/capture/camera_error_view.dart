import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// Shown instead of the viewfinder when the camera cannot open, with a way
/// to the phone settings when the permission was denied (HU01, scenario 2).
class CameraErrorView extends StatelessWidget {
  final String message;
  final bool showSettings;
  final VoidCallback onRetry;

  const CameraErrorView({
    super.key,
    required this.message,
    required this.showSettings,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBubble(
              icon: Icon(
                showSettings
                    ? Icons.no_photography_outlined
                    : Icons.error_outline_rounded,
              ),
              size: 72,
              background: AppColors.white.withValues(alpha: 0.12),
              color: AppColors.white,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            if (showSettings) ...[
              FilledButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Abrir ajustes'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: AppColors.white, width: 1.5),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
