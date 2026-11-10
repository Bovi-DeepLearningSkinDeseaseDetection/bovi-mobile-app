import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../focus_ring.dart';
import '../guide_frame.dart';

/// Live camera preview with the framing guide, the focus ring and the
/// shutter flash (HU01, HU03).
class CameraViewfinder extends StatelessWidget {
  final CameraController controller;
  final bool isSteady;
  final Offset? focusPosition;

  /// Changes on every tap, so the focus ring replays its animation.
  final int focusTaps;
  final bool showFlash;

  /// Tap position and size of the viewfinder, to focus there.
  final void Function(Offset tap, Size viewfinder) onTap;

  const CameraViewfinder({
    super.key,
    required this.controller,
    required this.isSteady,
    required this.focusPosition,
    required this.focusTaps,
    required this.showFlash,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => onTap(details.localPosition, constraints.biggest),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CoverCameraPreview(controller: controller),
            ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
            IgnorePointer(child: GuideFrame(isSteady: isSteady)),
            if (focusPosition != null)
              FocusRing(key: ValueKey(focusTaps), position: focusPosition!),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: showFlash ? 0.6 : 0,
                duration: const Duration(milliseconds: 120),
                child: const ColoredBox(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills the viewfinder with the camera preview, cropping the edges.
class _CoverCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _CoverCameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return Center(child: CameraPreview(controller));
    // The preview size is reported in landscape; swap it for portrait.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
