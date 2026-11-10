import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Buttons of the design system: solid green primary, green outlined
/// secondary and green text buttons.
class AppButtonThemes {
  AppButtonThemes._();

  static const _height = 52.0;
  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  static const _text = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Primary button: solid green, white text.
  static final filled = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.primaryGreen.withValues(alpha: 0.45),
      disabledForegroundColor: AppColors.white,
      minimumSize: const Size.fromHeight(_height),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: _shape,
      textStyle: _text,
      iconSize: 22,
    ),
  );

  /// Secondary button: white with a green outline.
  static final outlined = OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.secondaryText
            : AppColors.primaryGreen,
      ),
      backgroundColor: const WidgetStatePropertyAll(AppColors.white),
      overlayColor: WidgetStatePropertyAll(
        AppColors.lightGreen.withValues(alpha: 0.12),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? AppColors.softGray
              : AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(_height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20),
      ),
      shape: const WidgetStatePropertyAll(_shape),
      textStyle: const WidgetStatePropertyAll(_text),
      iconSize: const WidgetStatePropertyAll(22),
    ),
  );

  static final text = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryGreen,
      minimumSize: const Size(64, 44),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: _text.copyWith(fontSize: 15),
    ),
  );

  static final icon = IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppColors.primaryText),
  );
}
