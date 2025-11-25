import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/debt.dart';

abstract class DebtEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDebts extends DebtEvent {}
class AddDebt extends DebtEvent {
  final Debt debt;
  AddDebt(this.debt);
  @override
  List<Object?> get props => [debt];
}

class MarkDebtPaid extends DebtEvent {
  final String debtId;
  MarkDebtPaid(this.debtId);
  @override
  List<Object?> get props => [debtId];
}

abstract class DebtState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DebtInitial extends DebtState {}
class DebtLoading extends DebtState {}

class DebtLoaded extends DebtState {
  final List<Debt> debts;
  final double totalReceivable;
  final double totalPayable;

  DebtLoaded({required this.debts, required this.totalReceivable, required this.totalPayable});

  @override
  List<Object?> get props => [debts, totalReceivable, totalPayable];
}

class DebtOperationSuccess extends DebtState {
  final String message;
  DebtOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DebtError extends DebtState {
  final String message;
  DebtError(this.message);
  @override
  List<Object?> get props => [message];
}

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  DebtBloc() : super(DebtInitial()) {
    on<LoadDebts>(_onLoadDebts);
    on<AddDebt>(_onAddDebt);
    on<MarkDebtPaid>(_onMarkDebtPaid);
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadDebts(LoadDebts event, Emitter<DebtState> emit) async {
    emit(DebtLoading());
    try {
      final snapshot = await FirestoreService.instance.getCollection('users/$_userId/debts');
      final debts = snapshot.docs.map((doc) => Debt.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      final totalReceivable = debts.where((d) => d.type == DebtType.receivable && !d.isPaid).fold<double>(0, (sum, d) => sum + d.amount);
      final totalPayable = debts.where((d) => d.type == DebtType.payable && !d.isPaid).fold<double>(0, (sum, d) => sum + d.amount);

      emit(DebtLoaded(debts: debts, totalReceivable: totalReceivable, totalPayable: totalPayable));
    } catch (e) {
      emit(DebtLoaded(debts: [], totalReceivable: 0.0, totalPayable: 0.0));
    }
  }

  Future<void> _onAddDebt(AddDebt event, Emitter<DebtState> emit) async {
    try {
      await FirestoreService.instance.addDocument('users/$_userId/debts', event.debt.toMap());
      emit(DebtOperationSuccess('Debt added successfully'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtError('Failed to add debt: $e'));
    }
  }

  Future<void> _onMarkDebtPaid(MarkDebtPaid event, Emitter<DebtState> emit) async {
    try {
      await FirestoreService.instance.updateDocumentFields('users/$_userId/debts', event.debtId, {'isPaid': true});
      emit(DebtOperationSuccess('Debt marked as paid'));
      add(LoadDebts());
    } catch (e) {
      emit(DebtError('Failed to update debt: $e'));
    }
  }
}