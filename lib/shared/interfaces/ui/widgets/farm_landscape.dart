import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rural illustration of the design system: green rolling hills with trees,
/// a barn and grazing cows. It fills the space it is given.
class FarmLandscape extends StatelessWidget {
  /// Color of the front hill, which reaches the bottom edge.
  static const groundColor = AppColors.primaryGreen;

  const FarmLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Vacas pastando en el campo',
      child: const CustomPaint(size: Size.infinite, painter: _FarmPainter()),
    );
  }
}

class _FarmPainter extends CustomPainter {
  static const _cowColor = Color(0xFF0A3B27);

  const _FarmPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;
    // Scale of trees, barn and cows, designed for a 360 × 210 canvas.
    final s = math.min(w / 360, h / 210);

    double far(double x) => _wave(x, size, 0.40, 0.08, 0.85, 0.4);
    double back(double x) => _wave(x, size, 0.53, 0.06, 1.05, 2.6);
    double middle(double x) => _wave(x, size, 0.68, 0.04, 0.7, 4.2);
    double front(double x) => _wave(x, size, 0.87, 0.035, 1.3, 1.0);

    _hill(canvas, size, far, AppColors.mint);
    _tree(canvas, Offset(w * 0.07, far(w * 0.07) + 6 * s), 58 * s);
    _tree(
      canvas,
      Offset(w * 0.15, far(w * 0.15) + 6 * s),
      44 * s,
      canopy: AppColors.primaryGreen,
    );

    _hill(
      canvas,
      size,
      back,
      Color.alphaBlend(
        AppColors.lightGreen.withValues(alpha: 0.45),
        AppColors.white,
      ),
    );
    _barn(canvas, Offset(w * 0.74, back(w * 0.74) + 3 * s), s);
    _tree(canvas, Offset(w * 0.88, back(w * 0.88) + 6 * s), 62 * s);
    _tree(
      canvas,
      Offset(w * 0.95, back(w * 0.95) + 6 * s),
      46 * s,
      canopy: AppColors.primaryGreen,
    );

    _hill(canvas, size, middle, AppColors.lightGreen);
    _cow(canvas, Offset(w * 0.38, middle(w * 0.38) + 4 * s), 64 * s);
    _cow(
      canvas,
      Offset(w * 0.62, middle(w * 0.62) + 5 * s),
      54 * s,
      facingRight: false,
    );

    _hill(canvas, size, front, FarmLandscape.groundColor);
  }

  static double _wave(
    double x,
    Size size,
    double base,
    double amplitude,
    double frequency,
    double phase,
  ) {
    final angle = 2 * math.pi * frequency * x / size.width + phase;
    return size.height * (base + amplitude * math.cos(angle));
  }

  void _hill(
    Canvas canvas,
    Size size,
    double Function(double) top,
    Color color,
  ) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, top(0));
    for (var x = 4.0; x < size.width; x += 4) {
      path.lineTo(x, top(x));
    }
    path
      ..lineTo(size.width, top(size.width))
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Rounded tree standing on [ground].
  void _tree(
    Canvas canvas,
    Offset ground,
    double height, {
    Color canopy = AppColors.darkGreen,
  }) {
    final trunkHeight = height * 0.38;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          ground.dx - height * 0.035,
          ground.dy - trunkHeight,
          height * 0.07,
          trunkHeight,
        ),
        Radius.circular(height * 0.03),
      ),
      Paint()..color = AppColors.darkGreen,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ground.dx, ground.dy - trunkHeight - height * 0.27),
        width: height * 0.5,
        height: height * 0.72,
      ),
      Paint()..color = canopy,
    );
  }

  /// Small barn with a gabled roof and a white door.
  void _barn(Canvas canvas, Offset ground, double s) {
    final x = ground.dx;
    final y = ground.dy;
    final barn = Paint()..color = AppColors.darkGreen;
    canvas.drawRect(Rect.fromLTRB(x - 16 * s, y - 20 * s, x + 16 * s, y), barn);
    canvas.drawPath(
      Path()
        ..moveTo(x - 19 * s, y - 19 * s)
        ..lineTo(x, y - 34 * s)
        ..lineTo(x + 19 * s, y - 19 * s)
        ..close(),
      barn,
    );
    final trim = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s;
    final door = Rect.fromLTRB(x - 6 * s, y - 13 * s, x + 6 * s, y);
    canvas
      ..drawRect(door, trim)
      ..drawLine(door.topLeft, door.bottomRight, trim)
      ..drawLine(door.topRight, door.bottomLeft, trim)
      ..drawCircle(Offset(x, y - 25 * s), 2.6 * s, trim);
  }

  /// Cow silhouette whose hooves rest on [ground].
  void _cow(
    Canvas canvas,
    Offset ground,
    double length, {
    bool facingRight = true,
  }) {
    // Drawn facing right on a 60-unit long grid with the hooves at y = 0.
    final u = length / 60;
    canvas
      ..save()
      ..translate(ground.dx, ground.dy)
      ..scale(facingRight ? u : -u, u)
      ..translate(-30, 0);

    final paint = Paint()..color = _cowColor;
    final body = Path()
      // Torso.
      ..addRRect(RRect.fromLTRBR(6, -31, 43, -14, const Radius.circular(8)))
      // Neck.
      ..moveTo(36, -30)
      ..lineTo(48, -33)
      ..lineTo(51, -24)
      ..lineTo(39, -15)
      ..close()
      // Head and muzzle.
      ..addOval(
        Rect.fromCenter(center: const Offset(52, -29), width: 11, height: 12),
      )
      ..addOval(
        Rect.fromCenter(center: const Offset(56, -24), width: 8, height: 7),
      )
      // Ear.
      ..moveTo(47, -33)
      ..lineTo(42, -37)
      ..lineTo(48, -37.5)
      ..close()
      // Udder.
      ..addOval(
        Rect.fromCenter(center: const Offset(30, -14), width: 7, height: 5),
      );
    for (final legX in const [9.0, 15.5, 33.0, 38.5]) {
      body.addRRect(
        RRect.fromLTRBR(legX, -17, legX + 4, 0, const Radius.circular(1.5)),
      );
    }
    canvas.drawPath(body, paint);

    // Tail with its tuft.
    canvas.drawPath(
      Path()
        ..moveTo(7, -29)
        ..quadraticBezierTo(1, -24, 3, -12),
      Paint()
        ..color = _cowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(3, -11), width: 3.4, height: 5),
        paint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_FarmPainter oldDelegate) => false;
}
