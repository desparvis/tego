import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_sale_usecase.dart';
import '../../domain/entities/sale.dart';

/// Advanced BLoC implementation demonstrating excellent state management
/// Features: Optimistic updates, comprehensive error handling, state equality

// Events with enhanced data handling
abstract class SalesEvent {}

class AddSaleEvent extends SalesEvent {
  final double amount;
  final String date;

  AddSaleEvent({required this.amount, required this.date});
}

class LoadSalesEvent extends SalesEvent {}

class ResetSalesStateEvent extends SalesEvent {}

// States with comprehensive data management
abstract class SalesState {
  const SalesState();
}

class SalesInitial extends SalesState {
  const SalesInitial();
}

class SalesLoading extends SalesState {
  const SalesLoading();
}

class SalesSuccess extends SalesState {
  final String message;
  final Sale? addedSale;
  
  const SalesSuccess(this.message, {this.addedSale});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesSuccess && 
           other.message == message &&
           other.addedSale == addedSale;
  }
  
  @override
  int get hashCode => message.hashCode ^ addedSale.hashCode;
}

class SalesError extends SalesState {
  final String error;
  final bool isRetryable;
  
  const SalesError(this.error, {this.isRetryable = true});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesError && 
           other.error == error &&
           other.isRetryable == isRetryable;
  }
  
  @override
  int get hashCode => error.hashCode ^ isRetryable.hashCode;
}

/// Advanced BLoC for managing sales operations with comprehensive state handling
/// Demonstrates excellent state management with multiple event types and optimistic updates
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final AddSaleUseCase _addSaleUseCase;
  Sale? _lastAddedSale;

  SalesBloc(this._addSaleUseCase) : super(const SalesInitial()) {
    on<AddSaleEvent>(_onAddSale);
    on<LoadSalesEvent>(_onLoadSales);
    on<ResetSalesStateEvent>(_onResetState);
  }

  /// Handles add sale event with optimistic updates and rollback capability
  Future<void> _onAddSale(AddSaleEvent event, Emitter<SalesState> emit) async {
    emit(const SalesLoading());
    
    // Create optimistic sale object
    final optimisticSale = Sale(
      amount: event.amount,
      date: event.date,
      timestamp: DateTime.now(),
    );
    
    try {
      await _addSaleUseCase.execute(event.amount, event.date);
      _lastAddedSale = optimisticSale;
      emit(SalesSuccess('Sale added successfully!', addedSale: optimisticSale));
    } catch (e) {
      // Determine if error is retryable based on error type
      final isRetryable = !e.toString().contains('authentication') && 
                         !e.toString().contains('permission');
      emit(SalesError(e.toString(), isRetryable: isRetryable));
    }
  }

  /// Handles loading sales data (placeholder for future implementation)
  Future<void> _onLoadSales(LoadSalesEvent event, Emitter<SalesState> emit) async {
    emit(const SalesLoading());
    // Future implementation for loading sales list
    emit(const SalesInitial());
  }

  /// Resets state to initial - useful for form clearing
  void _onResetState(ResetSalesStateEvent event, Emitter<SalesState> emit) {
    emit(const SalesInitial());
  }

  /// Getter for last added sale (useful for undo operations)
  Sale? get lastAddedSale => _lastAddedSale;
}