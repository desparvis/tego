import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state_manager.dart';

/// Performance monitoring widget for development
/// 
/// Displays real-time performance metrics including:
/// - Frame rate (FPS)
/// - Memory usage
/// - State management metrics
/// - Network connectivity status
class PerformanceMonitor extends StatefulWidget {
  final Widget child;

  const PerformanceMonitor({
    super.key,
    required this.child,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showMetrics = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMetrics() {
    setState(() {
      _showMetrics = !_showMetrics;
      if (_showMetrics) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child; // Only show in debug mode
    }

    return Stack(
      children: [
        widget.child,
        
        // Performance metrics overlay
        if (_showMetrics)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationController.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Consumer<AppStateManager>(
                      builder: (context, appState, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Performance Metrics',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMetricRow('Online', appState.isOnline ? '✓' : '✗'),
                            ...appState.performanceMetrics.entries.map(
                              (entry) => _buildMetricRow(entry.key, '${entry.value}'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        
        // Toggle button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: GestureDetector(
            onTap: _toggleMetrics,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _showMetrics ? Icons.close : Icons.analytics,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}