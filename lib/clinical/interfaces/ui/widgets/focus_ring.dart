import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Converts a tap on a viewfinder that shows the preview cropped to cover it
/// (BoxFit.cover) into a normalized point (0-1) of the whole camera preview.
///
/// [previewSize] is the preview size in portrait orientation.
Offset tapToPreviewPoint(Offset tap, Size viewfinder, Size previewSize) {
  final scale = math.max(
    viewfinder.width / previewSize.width,
    viewfinder.height / previewSize.height,
  );
  final shownWidth = previewSize.width * scale;
  final shownHeight = previewSize.height * scale;
  final x = (tap.dx + (shownWidth - viewfinder.width) / 2) / shownWidth;
  final y = (tap.dy + (shownHeight - viewfinder.height) / 2) / shownHeight;
  return Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
}

/// Square that shrinks onto the tapped point and fades out, as camera apps
/// show when focusing. Give it a new key on each tap to replay it.
class FocusRing extends StatefulWidget {
  static const size = 72.0;

  final Offset position;

  const FocusRing({super.key, required this.position});

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - FocusRing.size / 2,
      top: widget.position.dy - FocusRing.size / 2,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            // Shrink during the first quarter, hold, then fade out.
            final shrink = Curves.easeOutBack.transform((t / 0.25).clamp(0, 1));
            final fade =
                1 - Curves.easeIn.transform(((t - 0.7) / 0.3).clamp(0, 1));
            return Opacity(
              opacity: fade,
              child: Transform.scale(scale: 1.4 - 0.4 * shrink, child: child),
            );
          },
          child: Container(
            width: FocusRing.size,
            height: FocusRing.size,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.guideGreen, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}
