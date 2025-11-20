import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_state_bloc.dart';
import '../../core/constants/app_constants.dart';

/// Widget demonstrating advanced BLoC state monitoring
/// Shows real-time app state and connectivity status
class BlocStatusIndicator extends StatelessWidget {
  const BlocStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateBloc, AppState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(state),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(state),
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(state),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(AppState state) {
    if (state is AppLoaded) {
      return state.isConnected ? Colors.green : Colors.orange;
    } else if (state is AppError) {
      return Colors.red;
    } else if (state is AppLoading) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(AppState state) {
    if (state is AppLoaded) {
      return state.isConnected ? Icons.cloud_done : Icons.cloud_off;
    } else if (state is AppError) {
      return Icons.error;
    } else if (state is AppLoading) {
      return Icons.sync;
    }
    return Icons.help;
  }

  String _getStatusText(AppState state) {
    if (state is AppLoaded) {
      return state.isConnected ? 'Online' : 'Offline';
    } else if (state is AppError) {
      return 'Error';
    } else if (state is AppLoading) {
      return 'Loading';
    }
    return 'Unknown';
  }
}