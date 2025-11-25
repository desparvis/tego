import 'package:flutter/material.dart';

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  // Responsive width
  static double w(double width) => screenWidth * (width / 375); // 375 is base width
  
  // Responsive height  
  static double h(double height) => screenHeight * (height / 812); // 812 is base height
  
  // Responsive font size
  static double sp(double fontSize) => fontSize * (screenWidth / 375);
  
  // Check if landscape
  static bool get isLandscape => _mediaQueryData.orientation == Orientation.landscape;
  
  // Check if tablet
  static bool get isTablet => screenWidth >= 600;
  
  // Safe area padding
  static EdgeInsets get safeAreaPadding => _mediaQueryData.padding;
  
  // Status bar height
  static double get statusBarHeight => _mediaQueryData.padding.top;
  
  // Bottom padding (for devices with home indicator)
  static double get bottomPadding => _mediaQueryData.padding.bottom;
}