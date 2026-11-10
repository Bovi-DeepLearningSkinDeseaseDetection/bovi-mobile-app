import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';

/// The analyzed photo, with rounded corners.
class ResultPhoto extends StatelessWidget {
  final String path;

  const ResultPhoto({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 210,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.softGray,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.secondaryText,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
