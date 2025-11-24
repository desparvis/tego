import 'package:flutter/foundation.dart';

/// Global app state manager using ChangeNotifier for reactive state
/// 
/// Provides efficient state management for:
/// - Connectivity status
/// - App lifecycle events  
/// - Performance monitoring
/// - Cache management
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // Connectivity state
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Performance metrics
  final Map<String, int> _performanceMetrics = {};
  Map<String, int> get performanceMetrics => Map.unmodifiable(_performanceMetrics);

  /// Update connectivity state and notify listeners efficiently
  void updateConnectivity(bool isConnected) {
    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      _recordMetric('connectivity_changes');
      notifyListeners();
    }
  }

  /// Record performance metrics for monitoring
  void recordMetric(String key) {
    _performanceMetrics[key] = (_performanceMetrics[key] ?? 0) + 1;
  }

  void _recordMetric(String key) {
    _performanceMetrics[key] = (_performanceMetrics[key] ?? 0) + 1;
  }
}