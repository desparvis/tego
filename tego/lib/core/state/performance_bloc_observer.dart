import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Performance monitoring BLoC observer
///
/// Tracks BLoC performance metrics including:
/// - State transition times
/// - Event processing duration
/// - Memory usage patterns
/// - Error rates
class PerformanceBlocObserver extends BlocObserver {
  final Map<String, DateTime> _eventStartTimes = {};
  final Map<String, List<Duration>> _transitionDurations = {};
  final Map<String, int> _errorCounts = {};

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    // Record event start time for performance tracking
    final key = '${bloc.runtimeType}_${event.runtimeType}';
    _eventStartTimes[key] = DateTime.now();

    if (kDebugMode) {
      debugPrint('🔄 Event: $event in ${bloc.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);

    // Calculate transition duration
    final key = '${bloc.runtimeType}_${transition.event.runtimeType}';
    final startTime = _eventStartTimes[key];

    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _transitionDurations.putIfAbsent(key, () => []).add(duration);

      // Log slow transitions (>100ms)
      if (duration.inMilliseconds > 100 && kDebugMode) {
        debugPrint(
          '⚠️ Slow transition: $key took ${duration.inMilliseconds}ms',
        );
      }

      _eventStartTimes.remove(key);
    }

    if (kDebugMode) {
      debugPrint(
        '🔀 Transition: ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    // Track error counts
    final key = bloc.runtimeType.toString();
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;

    if (kDebugMode) {
      debugPrint('❌ Error in ${bloc.runtimeType}: $error');
    }
  }

  /// Get performance metrics for monitoring
  Map<String, dynamic> getPerformanceMetrics() {
    final metrics = <String, dynamic>{};

    // Average transition durations
    _transitionDurations.forEach((key, durations) {
      if (durations.isNotEmpty) {
        final avgMs =
            durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
            durations.length;
        metrics['avg_${key}_ms'] = avgMs.round();
      }
    });

    // Error counts
    metrics['error_counts'] = Map.from(_errorCounts);

    return metrics;
  }

  /// Reset performance metrics
  void resetMetrics() {
    _eventStartTimes.clear();
    _transitionDurations.clear();
    _errorCounts.clear();
  }
}
