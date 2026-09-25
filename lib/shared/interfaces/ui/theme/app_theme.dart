import 'package:flutter/material.dart';
import './app_colors.dart';

/// Tema visual de Bovi

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fondo,

      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.verdePrincipal,
          primary: AppColors.verdePrincipal,
          secondary: AppColors.verdeClaro,
          surface: AppColors.blanco,
          error: AppColors.estadoLesion,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blanco,
        foregroundColor: AppColors.textoPrincipal,
        elevation: 0,
        centerTitle: false,
      ),

      // Boton principal
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blanco,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.blanco,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blanco,
        indicatorColor: AppColors.verdeClaro.withValues(alpha: 0.2),
        height: 64,
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textoPrincipal,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textoPrincipal,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textoPrincipal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textoPrincipal,
        ),
      ),
    );
  }
}