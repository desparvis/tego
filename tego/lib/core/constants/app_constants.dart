import 'package:flutter/material.dart';

class AppConstants {
  // App Colors - WCAG AA Compliant (4.5:1 contrast ratio)
  static const Color primaryPurple = Color(0xFF7B4EFF);
  static const Color primaryPurpleDark = Color(0xFF5A2FCC); // For better contrast
  static const Color accentPink = Color(0xFFF3E8FF);
  static const Color lightRed = Color(0xFFFFE4E1);
  static const Color textDark = Color(0xFF1A1A1A); // Enhanced contrast
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF757575);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  
  // App Strings
  static const String appName = 'Tego';
  
  // Design Specifications - Material Design 3
  static const double buttonRadius = 16.0;
  static const double cardRadius = 12.0;
  static const double defaultPadding = 20.0;
  static const double smallPadding = 16.0;
  static const double largePadding = 24.0;
  
  // Material Design minimum tap targets
  static const double minTapTarget = 48.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;
  
  // Text Styles
  static const String fontFamily = 'Poppins';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}