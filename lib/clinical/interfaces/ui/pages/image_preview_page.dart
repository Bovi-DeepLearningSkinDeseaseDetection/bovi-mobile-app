import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/origin_image.dart';

/// What the user decided on the preview screen.
enum PreviewDecision { analyze, retake }

/// Shows the captured or selected image before it is analyzed.
class ImagePreviewPage extends StatelessWidget {
  final CapturedImage image;

  const ImagePreviewPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final fromCamera = image.origin == ImageOrigin.camera;
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.softGray,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pop(PreviewDecision.analyze),
                    icon: const Icon(Icons.search),
                    label: const Text('Analizar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pop(PreviewDecision.retake),
                    icon: Icon(
                      fromCamera ? Icons.refresh : Icons.photo_library_outlined,
                    ),
                    label: Text(fromCamera ? 'Repetir' : 'Elegir otra'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
