import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Typography of the design system: Poppins for headlines and titles,
/// Inter for everything else.
class AppTextTheme {
  AppTextTheme._();

  static TextStyle _title(
    double size,
    FontWeight weight, {
    double height = 1.25,
    double letterSpacing = 0,
    Color color = AppColors.darkGreen,
  }) => TextStyle(
    fontFamily: AppFonts.titles,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );

  static TextStyle _body(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color = AppColors.primaryText,
  }) => TextStyle(
    fontFamily: AppFonts.body,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );

  static final textTheme = TextTheme(
    displaySmall: _title(
      34,
      FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    headlineLarge: _title(
      30,
      FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.4,
    ),
    headlineMedium: _title(24, FontWeight.w700, height: 1.2),
    headlineSmall: _title(20, FontWeight.w700),
    titleLarge: _title(
      18,
      FontWeight.w600,
      height: 1.3,
      color: AppColors.primaryText,
    ),
    titleMedium: _body(16, weight: FontWeight.w600, height: 1.35),
    titleSmall: _body(14, weight: FontWeight.w600, height: 1.35),
    bodyLarge: _body(16, height: 1.5),
    bodyMedium: _body(14, height: 1.45),
    bodySmall: _body(12, height: 1.4, color: AppColors.secondaryText),
    labelLarge: _body(
      16,
      weight: FontWeight.w600,
      letterSpacing: 0.1,
      color: null,
    ),
    labelMedium: _body(13, weight: FontWeight.w600, color: null),
    labelSmall: _body(12, weight: FontWeight.w500, color: null),
  );
}
