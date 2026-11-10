import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Bars, cards, dialogs, messages and lists of the design system.
class AppSurfaceThemes {
  AppSurfaceThemes._();

  static const appBar = AppBarTheme(
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
  );

  /// Back arrow "‹" of the screen mockups.
  static final actionIcons = ActionIconThemeData(
    backButtonIconBuilder: (_) =>
        const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
  );

  /// Mobile navigation bar: green icon and label on the selected item.
  static final navigationBar = NavigationBarThemeData(
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
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.primaryGreen : AppColors.secondaryText,
      );
    }),
  );

  /// Informative card: white, rounded, with a soft border and shadow.
  static final card = CardThemeData(
    color: AppColors.white,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.06),
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      side: BorderSide(color: AppColors.softGray),
    ),
  );

  static const dialog = DialogThemeData(
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
  );

  static final snackBar = SnackBarThemeData(
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
  );

  static const progressIndicator = ProgressIndicatorThemeData(
    color: AppColors.primaryGreen,
    linearTrackColor: AppColors.softGray,
    circularTrackColor: Colors.transparent,
    linearMinHeight: 8,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const listTile = ListTileThemeData(
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
  );

  static const divider = DividerThemeData(
    color: AppColors.softGray,
    thickness: 1,
    space: 1,
  );
}
