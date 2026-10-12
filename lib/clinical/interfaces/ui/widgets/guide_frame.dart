import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Framing guide displayed over the camera preview.
///
/// It reacts like modern camera apps: the corners slide in when the camera
/// opens, "breathe" in white while the phone moves, and lock onto the lesion
/// in green once the phone is held steady.
class GuideFrame extends StatefulWidget {
  /// Whether the phone is held steady enough to take a sharp photo.
  final bool isSteady;

  const GuideFrame({super.key, this.isSteady = true});

  static const instructionText = 'Encuadre la lesión dentro del marco';
  static const holdStillText = 'Mantenga el celular quieto';
  static const distanceText = '30 - 60 cm';

  @override
  State<GuideFrame> createState() => _GuideFrameState();
}

class _GuideFrameState extends State<GuideFrame> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final AnimationController _lock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: widget.isSteady ? 1 : 0,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBreathing();
  }

  @override
  void didUpdateWidget(GuideFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSteady != oldWidget.isSteady) {
      widget.isSteady ? _lock.forward() : _lock.reverse();
      _updateBreathing();
    }
  }

  // Breathing only while moving, and never when the user reduced motion.
  void _updateBreathing() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!widget.isSteady && !reduceMotion) {
      if (!_breath.isAnimating) _breath.repeat(reverse: true);
    } else {
      _breath
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _breath.dispose();
    _lock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steady = widget.isSteady;
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = (constraints.maxWidth * 0.66).clamp(
          0.0,
          constraints.maxHeight * 0.45,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DistanceBadge(isSteady: steady),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: Listenable.merge([_intro, _breath, _lock]),
              builder: (context, _) {
                final intro = Curves.easeOutCubic.transform(_intro.value);
                final breath = Curves.easeInOut.transform(_breath.value);
                final lock = Curves.easeOutBack.transform(_lock.value);
                final scale =
                    (1.15 - 0.15 * intro) *
                    (1 + 0.03 * breath) *
                    (1 - 0.04 * lock);
                return Opacity(
                  opacity: intro,
                  child: Transform.scale(
                    scale: scale,
                    child: CustomPaint(
                      size: Size.square(frameSize),
                      painter: _CornerPainter(
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.85),
                          AppColors.guideGreen,
                          _lock.value,
                        )!,
                        cornerLength: 24 + 8 * _lock.value,
                      ),
                    ),
                  ),
                );
              },
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
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    steady
                        ? GuideFrame.instructionText
                        : GuideFrame.holdStillText,
                    key: ValueKey(steady),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
  final bool isSteady;

  const _DistanceBadge({required this.isSteady});

  @override
  Widget build(BuildContext context) {
    final color = isSteady ? AppColors.guideGreen : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isSteady ? Icons.check_circle : Icons.straighten,
              key: ValueKey(isSteady),
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
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
  final Color color;
  final double cornerLength;

  _CornerPainter({required this.color, required this.cornerLength});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = color
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
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      color != oldDelegate.color || cornerLength != oldDelegate.cornerLength;
}
