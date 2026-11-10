import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// White panel under the viewfinder: gallery, shutter and history.
class CaptureControls extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onHistory;

  const CaptureControls({
    super.key,
    required this.isBusy,
    required this.onGallery,
    required this.onCapture,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SecondaryAction(
                icon: Icons.photo_library_outlined,
                label: 'Galería',
                onTap: onGallery,
              ),
              _CaptureButton(isBusy: isBusy, onTap: onCapture),
              _SecondaryAction(
                icon: Icons.article_outlined,
                label: 'Historial',
                onTap: onHistory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shutter: a green ring around a solid green button with a camera.
class _CaptureButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const _CaptureButton({required this.isBusy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capturar',
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGreen, width: 3),
        ),
        child: Material(
          color: AppColors.primaryGreen,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.photo_camera_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBubble(icon: Icon(icon), size: 48),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
