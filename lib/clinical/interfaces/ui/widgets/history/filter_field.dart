import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';

/// Row of the filter panel that opens a picker and can be cleared.
class FilterField extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  /// Removes the value; null hides the clear button.
  final VoidCallback? onClear;

  const FilterField({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.softGray),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Quitar filtro',
                  onPressed: onClear,
                )
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
