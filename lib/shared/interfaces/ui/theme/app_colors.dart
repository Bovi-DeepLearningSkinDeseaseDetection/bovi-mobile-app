import 'package:flutter/material.dart';

/// Color palette for the Bovi mobile app.
class AppColors {
  AppColors._();

  // Brand
  static const Color primaryGreen = Color(0xFF15803D);
  static const Color lightGreen = Color(0xFF67C23A);
  static const Color darkGreen = Color(0xFF0B5D3B);

  // Soft tints of the brand greens, for icon circles, chips and headers.
  static const Color mint = Color(0xFFE6F4DE);
  static const Color mist = Color(0xFFF3F9EF);

  // Camera framing guide
  static const Color guideGreen = lightGreen;

  // Surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color softGray = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFFFFFFF);
  static const Color neutralChip = Color(0xFFF3F4F6);

  // Text
  static const Color primaryText = Color(0xFF111827);
  static const Color bodyText = Color(0xFF4B5563);
  static const Color secondaryText = Color(0xFF6B7280);

  // Preliminary result status
  static const Color healthyStatus = Color(0xFF088342);
  static const Color reviewStatus = Color(0xFFB96F05);
  static const Color lesionStatus = Color(0xFFC40A31);

  // Status badges: background and text of each status.
  static const Color healthySurface = Color(0xFFE3F4DC);
  static const Color healthyText = healthyStatus;
  static const Color reviewSurface = Color(0xFFFEF3D7);
  static const Color reviewText = reviewStatus;
  static const Color lesionSurface = Color(0xFFFDE2E2);
  static const Color lesionText = lesionStatus;

  // Synchronization status
  static const Color synchronized = Color(0xFF15803D);
  static const Color pending = Color(0xFFF59E0B);
  static const Color offline = Color(0xFF9CA3AF);
}
