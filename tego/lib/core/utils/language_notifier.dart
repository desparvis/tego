import 'package:flutter/material.dart';

class LanguageNotifier {
  static final LanguageNotifier _instance = LanguageNotifier._internal();
  factory LanguageNotifier() => _instance;
  LanguageNotifier._internal();

  VoidCallback? _languageChangeListener;

  void setLanguageChangeListener(VoidCallback listener) {
    _languageChangeListener = listener;
  }

  void notifyLanguageChanged() {
    _languageChangeListener?.call();
  }
}