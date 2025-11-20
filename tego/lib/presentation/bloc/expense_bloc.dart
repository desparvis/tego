import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/expense.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  AddExpense(this.expense);
  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;
  DeleteExpense(this.expenseId);
  @override
  List<Object?> get props => [expenseId];
}

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

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(ExpenseError('User not authenticated'));
        return;
      }

      final snapshot = await FirestoreService.instance
          .getCollection('users/${user.uid}/expenses');
      
      final expenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      final totalAmount = expenses.fold<double>(0, (total, expense) => total + expense.amount);
      
      emit(ExpenseLoaded(expenses, totalAmount));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirestoreService.instance.addDocument(
        'users/${user.uid}/expenses',
        event.expense.toMap(),
      );
      
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirestoreService.instance.deleteDocument(
        'users/${user.uid}/expenses',
        event.expenseId,
      );
      
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }
}