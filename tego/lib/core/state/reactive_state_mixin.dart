import 'dart:async';
import 'package:flutter/widgets.dart';

/// Mixin for reactive state management with automatic disposal
/// 
/// Provides utilities for managing streams, subscriptions, and
/// reactive state updates with automatic cleanup
mixin ReactiveStateMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];

  /// Add a stream subscription with automatic disposal
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Create a stream controller with automatic disposal
  StreamController<T> createController<T>() {
    final controller = StreamController<T>();
    _controllers.add(controller);
    return controller;
  }

  /// Listen to a stream with automatic subscription management
  void listenToStream<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
    );
    addSubscription(subscription);
  }

  /// Debounce function calls to improve performance
  Timer? _debounceTimer;
  void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  DateTime? _lastThrottleTime;
  void throttle(VoidCallback callback, {Duration interval = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Close all controllers
    for (final controller in _controllers) {
      controller.close();
    }
    _controllers.clear();

    // Cancel debounce timer
    _debounceTimer?.cancel();

    super.dispose();
  }
}