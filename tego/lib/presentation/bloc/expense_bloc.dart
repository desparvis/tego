import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../core/error/failures.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class StreamExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  AddExpense(this.expense);
  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;
  UpdateExpense(this.expense);
  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;
  DeleteExpense(this.expenseId);
  @override
  List<Object?> get props => [expenseId];
}

class ResetExpenseState extends ExpenseEvent {}

// States
abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;
  
  ExpenseLoaded(this.expenses, this.totalAmount);
  
  @override
  List<Object?> get props => [expenses, totalAmount];
}

class ExpenseSuccess extends ExpenseState {
  final String message;
  final Expense? expense;
  
  ExpenseSuccess(this.message, {this.expense});
  
  @override
  List<Object?> get props => [message, expense];
}

class ExpenseError extends ExpenseState {
  final String message;
  final bool isRetryable;
  
  ExpenseError(this.message, {this.isRetryable = true});
  
  @override
  List<Object?> get props => [message, isRetryable];
}

// BLoC with comprehensive CRUD operations
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepositoryImpl? _repository;
  List<Expense> _currentExpenses = [];

  ExpenseBloc([this._repository]) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<StreamExpenses>(_onStreamExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<ResetExpenseState>(_onResetState);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    
    if (_repository == null) return;
    final result = await _repository.getExpenses();
    result.fold(
      (failure) {
        final isRetryable = failure is! AuthenticationFailure;
        emit(ExpenseError(failure.message, isRetryable: isRetryable));
      },
      (expenses) {
        _currentExpenses = expenses;
        final totalAmount = expenses.fold<double>(0, (total, expense) => total + expense.amount);
        emit(ExpenseLoaded(expenses, totalAmount));
      },
    );
  }

  Future<void> _onStreamExpenses(StreamExpenses event, Emitter<ExpenseState> emit) async {
    await emit.forEach(
      _repository?.streamExpenses() ?? const Stream.empty(),
      onData: (result) {
        return result.fold(
          (failure) {
            final isRetryable = failure is! AuthenticationFailure;
            return ExpenseError(failure.message, isRetryable: isRetryable);
          },
          (expenses) {
            _currentExpenses = expenses;
            final totalAmount = expenses.fold<double>(0, (total, expense) => total + expense.amount);
            return ExpenseLoaded(expenses, totalAmount);
          },
        );
      },
    );
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    
    // Optimistic update
    final optimisticExpenses = [..._currentExpenses, event.expense];
    final optimisticTotal = optimisticExpenses.fold<double>(0, (total, expense) => total + expense.amount);
    emit(ExpenseLoaded(optimisticExpenses, optimisticTotal));
    
    if (_repository == null) return;
    final result = await _repository.addExpense(event.expense);
    result.fold(
      (failure) {
        // Revert optimistic update
        final totalAmount = _currentExpenses.fold<double>(0, (total, expense) => total + expense.amount);
        emit(ExpenseLoaded(_currentExpenses, totalAmount));
        
        final isRetryable = failure is! AuthenticationFailure;
        emit(ExpenseError(failure.message, isRetryable: isRetryable));
      },
      (_) {
        emit(ExpenseSuccess('Expense added successfully!', expense: event.expense));
      },
    );
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    
    if (_repository == null) return;
    final result = await _repository.updateExpense(event.expense);
    result.fold(
      (failure) {
        final isRetryable = failure is! AuthenticationFailure;
        emit(ExpenseError(failure.message, isRetryable: isRetryable));
      },
      (_) {
        emit(ExpenseSuccess('Expense updated successfully!', expense: event.expense));
        add(LoadExpenses()); // Refresh list
      },
    );
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    
    // Optimistic update
    final optimisticExpenses = _currentExpenses.where((e) => e.id != event.expenseId).toList();
    final optimisticTotal = optimisticExpenses.fold<double>(0, (total, expense) => total + expense.amount);
    emit(ExpenseLoaded(optimisticExpenses, optimisticTotal));
    
    if (_repository == null) return;
    final result = await _repository.deleteExpense(event.expenseId);
    result.fold(
      (failure) {
        // Revert optimistic update
        final totalAmount = _currentExpenses.fold<double>(0, (total, expense) => total + expense.amount);
        emit(ExpenseLoaded(_currentExpenses, totalAmount));
        
        final isRetryable = failure is! AuthenticationFailure;
        emit(ExpenseError(failure.message, isRetryable: isRetryable));
      },
      (_) {
        _currentExpenses = optimisticExpenses;
        emit(ExpenseSuccess('Expense deleted successfully!'));
      },
    );
  }

  void _onResetState(ResetExpenseState event, Emitter<ExpenseState> emit) {
    emit(ExpenseInitial());
  }
}