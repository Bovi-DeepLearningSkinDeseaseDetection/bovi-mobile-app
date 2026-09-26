import 'package:flutter/material.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Guía de encuadre sobre la vista de cámara
class MarcoGuia extends StatelessWidget {
  const MarcoGuia({super.key});

  static const texto = 'Acérquese a 30–60 cm y centre la lesión en el recuadro';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final lado = (c.maxWidth * 0.7).clamp(0.0, c.maxHeight * 0.6);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: lado,
              height: lado,
              child: Stack(
                children: [
                  CustomPaint(size: Size(lado, lado), painter: _Esquinas()),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _chipDistancia(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  texto,
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

  Widget _chipDistancia() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.straighten, size: 16, color: AppColors.verdeClaro),
          SizedBox(width: 4),
          Text('30–60 cm',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Dibuja solo las cuatro esquinas en L del recuadro.
class _Esquinas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const largo = 32.0;
    final w = size.width, h = size.height;
    final p = Paint()
      ..color = AppColors.verdeClaro
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(Path()..moveTo(0, largo)..lineTo(0, 0)..lineTo(largo, 0), p);
    canvas.drawPath(Path()..moveTo(w - largo, 0)..lineTo(w, 0)..lineTo(w, largo), p);
    canvas.drawPath(Path()..moveTo(0, h - largo)..lineTo(0, h)..lineTo(largo, h), p);
    canvas.drawPath(Path()..moveTo(w - largo, h)..lineTo(w, h)..lineTo(w, h - largo), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}