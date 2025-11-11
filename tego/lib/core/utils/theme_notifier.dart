import 'package:flutter/material.dart';

class ThemeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  VoidCallback? _onThemeChanged;

  void setThemeChangeListener(VoidCallback callback) {
    _onThemeChanged = callback;
  }

  void notifyThemeChanged() {
    _onThemeChanged?.call();
  }
}