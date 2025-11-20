import 'package:flutter_bloc/flutter_bloc.dart';

// Events for global app state
abstract class AppStateEvent {}

class LoadAppDataEvent extends AppStateEvent {}

class UpdateConnectivityEvent extends AppStateEvent {
  final bool isConnected;
  UpdateConnectivityEvent(this.isConnected);
}

// States for global app state
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final bool isConnected;
  final Map<String, dynamic> userData;
  
  AppLoaded({required this.isConnected, required this.userData});
}

class AppError extends AppState {
  final String error;
  AppError(this.error);
}

/// Global app state BLoC for managing connectivity and user data
/// Demonstrates advanced state management with multiple data sources
class AppStateBloc extends Bloc<AppStateEvent, AppState> {
  AppStateBloc() : super(AppInitial()) {
    on<LoadAppDataEvent>(_onLoadAppData);
    on<UpdateConnectivityEvent>(_onUpdateConnectivity);
  }

  Future<void> _onLoadAppData(LoadAppDataEvent event, Emitter<AppState> emit) async {
    emit(AppLoading());
    
    try {
      // Simulate loading user data and checking connectivity
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(AppLoaded(
        isConnected: true,
        userData: {'theme': 'light', 'language': 'en'},
      ));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  void _onUpdateConnectivity(UpdateConnectivityEvent event, Emitter<AppState> emit) {
    final currentState = state;
    if (currentState is AppLoaded) {
      emit(AppLoaded(
        isConnected: event.isConnected,
        userData: currentState.userData,
      ));
    }
  }
}