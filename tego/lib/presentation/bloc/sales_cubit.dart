import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/add_sale_usecase.dart';


/// Cubit state for sales operations
class SalesState extends Equatable {
  final List<Sale> sales;
  final bool isLoading;
  final String? error;
  final Sale? lastAdded;

  const SalesState({
    this.sales = const [],
    this.isLoading = false,
    this.error,
    this.lastAdded,
  });

  SalesState copyWith({
    List<Sale>? sales,
    bool? isLoading,
    String? error,
    Sale? lastAdded,
  }) {
    return SalesState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAdded: lastAdded ?? this.lastAdded,
    );
  }

  @override
  List<Object?> get props => [sales, isLoading, error, lastAdded];
}

/// High-performance Cubit for sales operations
/// 
/// Uses Cubit instead of BLoC for simpler state management where
/// events are not needed, providing better performance for
/// straightforward state updates
class SalesCubit extends Cubit<SalesState> {
  final AddSaleUseCase _addSaleUseCase;

  SalesCubit(this._addSaleUseCase) : super(const SalesState());

  /// Add sale with optimistic updates for immediate UI response
  Future<void> addSale(double amount, String date) async {
    // Optimistic update - immediately show loading state
    emit(state.copyWith(isLoading: true, error: null));

    // Create optimistic sale for immediate UI feedback
    final optimisticSale = Sale(
      amount: amount,
      date: date,
      timestamp: DateTime.now(),
    );

    // Optimistically add to local state
    final updatedSales = [...state.sales, optimisticSale];
    emit(state.copyWith(
      sales: updatedSales,
      isLoading: true,
      lastAdded: optimisticSale,
    ));

    // Execute use case
    final result = await _addSaleUseCase.execute(amount, date);

    result.fold(
      (failure) {
        // Rollback optimistic update on failure
        final rolledBackSales = state.sales
            .where((sale) => sale != optimisticSale)
            .toList();
        
        emit(state.copyWith(
          sales: rolledBackSales,
          isLoading: false,
          error: failure.message,
          lastAdded: null,
        ));
      },
      (_) {
        // Confirm successful addition
        emit(state.copyWith(
          isLoading: false,
          error: null,
        ));
      },
    );
  }

  /// Clear error state
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Reset to initial state
  void reset() {
    emit(const SalesState());
  }
}