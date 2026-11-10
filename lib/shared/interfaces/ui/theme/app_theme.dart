import 'package:flutter/material.dart';

import 'app_button_themes.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_input_themes.dart';
import 'app_surface_themes.dart';
import 'app_text_theme.dart';

export 'app_fonts.dart';

/// Bovi visual theme (Material 3), assembled from the themes of each group
/// of components.
class AppTheme {
  AppTheme._();

  static final _colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryGreen,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    primary: AppColors.primaryGreen,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.mint,
    onPrimaryContainer: AppColors.darkGreen,
    secondary: AppColors.lightGreen,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.mint,
    onSecondaryContainer: AppColors.darkGreen,
    tertiary: AppColors.darkGreen,
    onTertiary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.primaryText,
    onSurfaceVariant: AppColors.secondaryText,
    surfaceTint: Colors.transparent,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.mist,
    surfaceContainer: AppColors.mist,
    surfaceContainerHigh: AppColors.mint,
    surfaceContainerHighest: AppColors.mint,
    outline: const Color(0xFFD1D5DB),
    outlineVariant: AppColors.softGray,
    error: AppColors.lesionStatus,
    onError: AppColors.white,
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.body,
    textTheme: AppTextTheme.textTheme,
    dividerColor: AppColors.softGray,
    // Buttons.
    filledButtonTheme: AppButtonThemes.filled,
    outlinedButtonTheme: AppButtonThemes.outlined,
    textButtonTheme: AppButtonThemes.text,
    iconButtonTheme: AppButtonThemes.icon,
    // Fields and chips.
    inputDecorationTheme: AppInputThemes.inputDecoration,
    searchBarTheme: AppInputThemes.searchBar,
    chipTheme: AppInputThemes.chip,
    // Bars, surfaces and messages.
    appBarTheme: AppSurfaceThemes.appBar,
    actionIconTheme: AppSurfaceThemes.actionIcons,
    navigationBarTheme: AppSurfaceThemes.navigationBar,
    cardTheme: AppSurfaceThemes.card,
    dialogTheme: AppSurfaceThemes.dialog,
    snackBarTheme: AppSurfaceThemes.snackBar,
    progressIndicatorTheme: AppSurfaceThemes.progressIndicator,
    listTileTheme: AppSurfaceThemes.listTile,
    dividerTheme: AppSurfaceThemes.divider,
  );
}
