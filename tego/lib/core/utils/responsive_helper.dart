import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide <= 360; // ≤5.5" screens
  }
  
  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= 414; // ≥6.7" screens
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    
    if (shortestSide <= 360) {
      return baseSize * 0.85;
    } else if (shortestSide >= 414) {
      return baseSize * 1.15;
    } else if (shortestSide >= 768) { // Tablet
      return baseSize * 1.3;
    }
    return baseSize;
  }
  
  static double getResponsivePadding(BuildContext context, double basePadding) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    
    if (shortestSide <= 360) {
      return basePadding * 0.75;
    } else if (shortestSide >= 414) {
      return basePadding * 1.25;
    } else if (shortestSide >= 768) { // Tablet
      return basePadding * 1.5;
    }
    return basePadding;
  }
  
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    
    if (shortestSide <= 360) {
      return const EdgeInsets.all(8);
    } else if (shortestSide >= 414) {
      return const EdgeInsets.all(20);
    } else if (shortestSide >= 768) { // Tablet
      return const EdgeInsets.all(32);
    }
    return const EdgeInsets.all(16);
  }
  
  static int getGridColumns(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width >= 768) return 3; // Tablet
    if (size.width >= 414) return 2; // Large phone
    return 2; // Default
  }
  
  static double getCardHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.shortestSide >= 768) return 120; // Tablet
    if (size.shortestSide <= 360) return 80;  // Small phone
    return 100; // Default
  }
}