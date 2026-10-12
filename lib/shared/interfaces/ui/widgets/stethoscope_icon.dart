import 'package:flutter/material.dart';

/// Outlined stethoscope, the "Diagnóstico / Analizar" icon of the design
/// system. Material Icons has no stethoscope, so it is drawn here.
///
/// Like [Icon], it takes its size and color from the [IconTheme].
class StethoscopeIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const StethoscopeIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = size ?? iconTheme.size ?? 24;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(iconSize),
        painter: _StethoscopePainter(
          color: color ?? iconTheme.color ?? Colors.black,
        ),
      ),
    );
  }
}

class _StethoscopePainter extends CustomPainter {
  final Color color;

  _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 24 × 24 grid, like Material icons.
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ear tips.
    canvas
      ..drawLine(const Offset(5, 2), const Offset(5, 4), paint)
      ..drawLine(const Offset(11, 2), const Offset(11, 4), paint);

    // Binaural tubes joining into a U.
    canvas.drawPath(
      Path()
        ..moveTo(5, 3)
        ..lineTo(4, 3)
        ..arcToPoint(
          const Offset(2, 5),
          radius: const Radius.circular(2),
          clockwise: false,
        )
        ..lineTo(2, 9)
        ..arcToPoint(
          const Offset(14, 9),
          radius: const Radius.circular(6),
          clockwise: false,
        )
        ..lineTo(14, 5)
        ..arcToPoint(
          const Offset(12, 3),
          radius: const Radius.circular(2),
          clockwise: false,
        )
        ..lineTo(11, 3),
      paint,
    );

    // Tube down to the chest piece.
    canvas.drawPath(
      Path()
        ..moveTo(8, 15)
        ..arcToPoint(
          const Offset(20, 15),
          radius: const Radius.circular(6),
          clockwise: false,
        )
        ..lineTo(20, 12),
      paint,
    );
    canvas.drawCircle(const Offset(20, 10), 2, paint);
  }

  @override
  bool shouldRepaint(_StethoscopePainter oldDelegate) =>
      color != oldDelegate.color;
}
