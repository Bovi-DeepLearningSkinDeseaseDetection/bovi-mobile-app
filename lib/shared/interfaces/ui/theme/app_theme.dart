import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './app_colors.dart';

/// Font families of the design system: Poppins for titles, Inter for text.
class AppFonts {
  AppFonts._();

  static const titles = 'Poppins';
  static const body = 'Inter';
}

/// Bovi visual theme.
class AppTheme {
  AppTheme._();

  static const _buttonHeight = 52.0;
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  static const _buttonText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
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

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,
      textTheme: _textTheme,
      dividerColor: AppColors.softGray,

      // Back arrow "‹" of the screen mockups.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mist,
        foregroundColor: AppColors.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.titles,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        iconTheme: IconThemeData(color: AppColors.primaryText),
        actionsIconTheme: IconThemeData(color: AppColors.primaryText),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Primary button: solid green, white text.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primaryGreen.withValues(
            alpha: 0.45,
          ),
          disabledForegroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(_buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: _buttonShape,
          textStyle: _buttonText,
          iconSize: 22,
        ),
      ),

      // Kept in line with the primary button for any ElevatedButton left.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(_buttonHeight),
          shape: _buttonShape,
          textStyle: _buttonText,
        ),
      ),

      // Secondary button: white with a green outline.
      outlinedButtonTheme: OutlinedButtonThemeData(
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
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(_buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20),
          ),
          shape: const WidgetStatePropertyAll(_buttonShape),
          textStyle: const WidgetStatePropertyAll(_buttonText),
          iconSize: const WidgetStatePropertyAll(22),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          minimumSize: const Size(64, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: _buttonText.copyWith(fontSize: 15),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primaryText),
      ),

      // Informative card: white, rounded, with a soft border and shadow.
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AppColors.softGray),
        ),
      ),

      // Search field / input: rounded pill with a soft gray border.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
          color: AppColors.secondaryText,
        ),
        prefixIconColor: AppColors.secondaryText,
        suffixIconColor: AppColors.secondaryText,
        border: _inputBorder(AppColors.softGray),
        enabledBorder: _inputBorder(AppColors.softGray),
        focusedBorder: _inputBorder(AppColors.primaryGreen, width: 1.5),
        errorBorder: _inputBorder(AppColors.lesionStatus),
        focusedErrorBorder: _inputBorder(AppColors.lesionStatus, width: 1.5),
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(AppColors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: WidgetStatePropertyAll(
          AppColors.lightGreen.withValues(alpha: 0.08),
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? AppColors.primaryGreen
                : AppColors.softGray,
            width: states.contains(WidgetState.focused) ? 1.5 : 1,
          ),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        constraints: const BoxConstraints(minHeight: 52),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 15,
            color: AppColors.primaryText,
          ),
        ),
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 15,
            color: AppColors.secondaryText,
          ),
        ),
      ),

      // UI style chips: soft green pills.
      chipTheme: const ChipThemeData(
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
      ),

      // Mobile navigation bar: green icon and label on the selected item.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        overlayColor: WidgetStatePropertyAll(
          AppColors.lightGreen.withValues(alpha: 0.10),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryGreen
                : AppColors.secondaryText,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryGreen
                : AppColors.secondaryText,
          ),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.titles,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: AppColors.darkGreen,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
          height: 1.5,
          color: AppColors.bodyText,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGreen,
        actionTextColor: AppColors.lightGreen,
        elevation: 2,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 14,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGreen,
        linearTrackColor: AppColors.softGray,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 8,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 12,
        iconColor: AppColors.darkGreen,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13,
          color: AppColors.secondaryText,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.softGray,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // Poppins for headlines and titles, Inter for everything else.
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontFamily: AppFonts.titles,
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.5,
      color: AppColors.darkGreen,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppFonts.titles,
      fontSize: 30,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.4,
      color: AppColors.darkGreen,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.titles,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.darkGreen,
    ),
    headlineSmall: TextStyle(
      fontFamily: AppFonts.titles,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.darkGreen,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.titles,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.primaryText,
    ),
    titleMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.primaryText,
    ),
    titleSmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.primaryText,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      height: 1.5,
      color: AppColors.primaryText,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14,
      height: 1.45,
      color: AppColors.primaryText,
    ),
    bodySmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      height: 1.4,
      color: AppColors.secondaryText,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}
