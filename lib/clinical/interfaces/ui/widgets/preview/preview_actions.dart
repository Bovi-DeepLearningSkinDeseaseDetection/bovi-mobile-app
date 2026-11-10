import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../../shared/interfaces/ui/widgets/stethoscope_icon.dart';

/// Hint and the "Analizar" and retake buttons of the preview (HU01, HU02).
class PreviewActions extends StatelessWidget {
  final bool isAnalyzing;
  final bool fromCamera;
  final VoidCallback onAnalyze;
  final VoidCallback onRetake;

  const PreviewActions({
    super.key,
    required this.isAnalyzing,
    required this.fromCamera,
    required this.onAnalyze,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Revise que la lesión se vea nítida y bien iluminada.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isAnalyzing ? null : onAnalyze,
              icon: isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const StethoscopeIcon(),
              label: Text(isAnalyzing ? 'Analizando…' : 'Analizar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isAnalyzing ? null : onRetake,
              icon: Icon(
                fromCamera
                    ? Icons.refresh_rounded
                    : Icons.photo_library_outlined,
              ),
              label: Text(fromCamera ? 'Repetir' : 'Elegir otra'),
            ),
          ],
        ),
      ),
    );
  }
}
