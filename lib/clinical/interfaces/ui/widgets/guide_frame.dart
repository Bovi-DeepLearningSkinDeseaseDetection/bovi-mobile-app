import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Framing guide displayed over the camera preview.
class GuideFrame extends StatelessWidget {
  const GuideFrame({super.key});

  static const instructionText =
      'Move within 30–60 cm and center the lesion in the frame';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = (constraints.maxWidth * 0.7).clamp(
          0.0,
          constraints.maxHeight * 0.6,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: frameSize,
              height: frameSize,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(frameSize, frameSize),
                    painter: _CornerPainter(),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _DistanceBadge(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  instructionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.straighten, size: 16, color: AppColors.lightGreen),
          SizedBox(width: 4),
          Text('30–60 cm', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Draws only the four L-shaped corners of the frame.
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 32.0;
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = AppColors.lightGreen
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

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
