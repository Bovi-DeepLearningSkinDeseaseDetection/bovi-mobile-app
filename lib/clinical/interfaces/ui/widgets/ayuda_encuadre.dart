import 'package:flutter/material.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Ayuda con ejemplos de foto correcta e incorrecta
Future<void> mostrarAyudaEncuadre(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('¿Cómo tomar una buena foto?',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _Ejemplo(
                    asset: 'assets/images/ejemplo_correcto.jpg',
                    correcto: true,
                    texto: 'Cerca, centrada y con buena luz',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _Ejemplo(
                    asset: 'assets/images/ejemplo_incorrecto.jpg',
                    correcto: false,
                    texto: 'Lejos, borrosa u oscura',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Ejemplo extends StatelessWidget {
  final String asset;
  final bool correcto;
  final String texto;

  const _Ejemplo({
    required this.asset,
    required this.correcto,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.grisSuave,
                child: const Icon(Icons.image_outlined,
                    color: AppColors.textoSecundario),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correcto ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: correcto ? AppColors.estadoSaludable : AppColors.estadoLesion,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}