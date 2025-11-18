import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_sale_usecase.dart';

// Events
abstract class SalesEvent {}

class AddSaleEvent extends SalesEvent {
  final double amount;
  final String date;

  AddSaleEvent({required this.amount, required this.date});
}

// States
abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesSuccess extends SalesState {
  final String message;
  
  SalesSuccess(this.message);
}

class SalesError extends SalesState {
  final String error;
  
  SalesError(this.error);
}

/// BLoC for managing sales operations
/// Handles UI state and delegates business logic to use cases
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final AddSaleUseCase _addSaleUseCase;

  SalesBloc(this._addSaleUseCase) : super(SalesInitial()) {
    on<AddSaleEvent>(_onAddSale);
  }

  /// Handles add sale event with proper error handling
  Future<void> _onAddSale(AddSaleEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());
    
    try {
      await _addSaleUseCase.execute(event.amount, event.date);
      emit(SalesSuccess('Sale added successfully!'));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}