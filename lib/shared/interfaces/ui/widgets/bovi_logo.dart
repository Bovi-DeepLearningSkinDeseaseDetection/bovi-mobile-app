import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Main logo: the app icon, the "Bovi" wordmark and the tagline.
class BoviLogo extends StatelessWidget {
  static const iconAsset = 'assets/icon/bovi_icon.png';
  static const tagline = 'salud de la piel bovina';

  /// Height of the icon. The wordmark and the tagline scale with it.
  final double size;

  const BoviLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bovi, $tagline',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BoviIcon(size: size),
            SizedBox(width: size * 0.22),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoviWordmark(fontSize: size * 0.62),
                Text(
                  tagline,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontFamily: AppFonts.titles,
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simplified icon: the cow with the health cross on a rounded square.
class BoviIcon extends StatelessWidget {
  final double size;

  const BoviIcon({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        BoviLogo.iconAsset,
        width: size,
        height: size,
        cacheWidth: pixels,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => SizedBox.square(
          dimension: size,
          child: const ColoredBox(color: AppColors.primaryGreen),
        ),
      ),
    );
  }
}

/// "Bovi" written in Poppins with a light green leaf as the dot of the i.
class BoviWordmark extends StatelessWidget {
  final double fontSize;
  final Color color;

  const BoviWordmark({
    super.key,
    this.fontSize = 28,
    this.color = AppColors.darkGreen,
  });

  @override
  Widget build(BuildContext context) {
    final layout = _WordmarkLayout(fontSize: fontSize, color: color);
    final size = layout.size;
    layout.dispose();
    return Semantics(
      label: 'Bovi',
      child: CustomPaint(
        size: size,
        painter: _WordmarkPainter(fontSize: fontSize, color: color),
      ),
    );
  }
}

/// Measures the wordmark and places the leaf over the dotless i.
class _WordmarkLayout {
  // The last letter is a dotless i (U+0131); the leaf replaces its dot.
  static const _text = 'Bovı';

  final TextPainter text;
  late final Offset textOffset;
  late final Offset leafCenter;
  late final double leafLength;
  late final Size size;

  _WordmarkLayout({required double fontSize, required Color color})
    : text = TextPainter(
        text: TextSpan(
          text: _text,
          style: TextStyle(
            fontFamily: AppFonts.titles,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -fontSize * 0.02,
            height: 1.0,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
        maxLines: 1,
      ) {
    text.layout();
    final baseline = text.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final iStart = text.getOffsetForCaret(
      const TextPosition(offset: _text.length - 1),
      Rect.zero,
    );
    final iCenter = (iStart.dx + text.width) / 2;

    leafLength = fontSize * 0.42;
    // The leaf sits just above the x-height, tilted to the right.
    final leaf = Offset(iCenter + fontSize * 0.08, baseline - fontSize * 0.8);
    final top = math.min(0.0, leaf.dy - leafLength / 2);
    final right = math.max(text.width, leaf.dx + leafLength / 2);

    textOffset = Offset(0, -top);
    leafCenter = leaf.translate(0, -top);
    size = Size(right, text.height - top);
  }

  void dispose() => text.dispose();
}

class _WordmarkPainter extends CustomPainter {
  final double fontSize;
  final Color color;

  _WordmarkPainter({required this.fontSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final layout = _WordmarkLayout(fontSize: fontSize, color: color);
    layout.text.paint(canvas, layout.textOffset);
    paintLeaf(
      canvas,
      center: layout.leafCenter,
      length: layout.leafLength,
      angle: math.pi / 4.5,
      color: AppColors.lightGreen,
    );
    layout.dispose();
  }

  @override
  bool shouldRepaint(_WordmarkPainter oldDelegate) =>
      fontSize != oldDelegate.fontSize || color != oldDelegate.color;
}

/// Paints an almond-shaped leaf with its tip pointing along [angle]
/// (0 points up, positive turns clockwise).
void paintLeaf(
  Canvas canvas, {
  required Offset center,
  required double length,
  required double angle,
  required Color color,
}) {
  final half = length / 2;
  final width = length * 0.36;
  final leaf = Path()
    ..moveTo(0, half)
    ..quadraticBezierTo(width * 1.15, half * 0.15, 0, -half)
    ..quadraticBezierTo(-width * 1.15, -half * 0.15, 0, half)
    ..close();
  canvas
    ..save()
    ..translate(center.dx, center.dy)
    ..rotate(angle)
    ..drawPath(leaf, Paint()..color = color)
    ..restore();
}
