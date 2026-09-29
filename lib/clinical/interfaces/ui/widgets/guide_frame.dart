import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Framing guide displayed over the camera preview.
class GuideFrame extends StatelessWidget {
  const GuideFrame({super.key});

  static const instructionText = 'Encuadre la lesión dentro del marco';
  static const distanceText = '30 - 60 cm';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = (constraints.maxWidth * 0.66).clamp(
          0.0,
          constraints.maxHeight * 0.45,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _DistanceBadge(),
            const SizedBox(height: 18),
            CustomPaint(
              size: Size.square(frameSize),
              painter: _CornerPainter(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  instructionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.guideGreen),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.straighten, size: 14, color: AppColors.guideGreen),
          SizedBox(width: 4),
          Text(
            GuideFrame.distanceText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws only the four L-shaped corners of the frame.
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 24.0;
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = AppColors.guideGreen
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(width - cornerLength, 0)
        ..lineTo(width, 0)
        ..lineTo(width, cornerLength),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, height - cornerLength)
        ..lineTo(0, height)
        ..lineTo(cornerLength, height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(width - cornerLength, height)
        ..lineTo(width, height)
        ..lineTo(width, height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
