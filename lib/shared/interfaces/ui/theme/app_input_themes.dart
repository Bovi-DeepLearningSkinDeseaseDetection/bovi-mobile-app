import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Search field, text fields and chips of the design system.
class AppInputThemes {
  AppInputThemes._();

  static const _fieldText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    color: AppColors.primaryText,
  );
  static const _hintText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    color: AppColors.secondaryText,
  );

  /// Text fields: rounded with a soft gray border, green when focused.
  static final inputDecoration = InputDecorationThemeData(
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    hintStyle: _hintText,
    prefixIconColor: AppColors.secondaryText,
    suffixIconColor: AppColors.secondaryText,
    border: _border(AppColors.softGray),
    enabledBorder: _border(AppColors.softGray),
    focusedBorder: _border(AppColors.primaryGreen, width: 1.5),
    errorBorder: _border(AppColors.lesionStatus),
    focusedErrorBorder: _border(AppColors.lesionStatus, width: 1.5),
  );

  /// Search field: a white pill with a soft gray border.
  static final searchBar = SearchBarThemeData(
    elevation: const WidgetStatePropertyAll(0),
    backgroundColor: const WidgetStatePropertyAll(AppColors.white),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    overlayColor: WidgetStatePropertyAll(
      AppColors.lightGreen.withValues(alpha: 0.08),
    ),
    side: WidgetStateProperty.resolveWith((states) {
      final focused = states.contains(WidgetState.focused);
      return BorderSide(
        color: focused ? AppColors.primaryGreen : AppColors.softGray,
        width: focused ? 1.5 : 1,
      );
    }),
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
    constraints: const BoxConstraints(minHeight: 52),
    textStyle: const WidgetStatePropertyAll(_fieldText),
    hintStyle: const WidgetStatePropertyAll(_hintText),
  );

  /// Chips: soft green pills.
  static const chip = ChipThemeData(
    backgroundColor: AppColors.mint,
    side: BorderSide.none,
    shape: StadiumBorder(),
    labelStyle: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.darkGreen,
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  );

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color, width: width),
      );
}
