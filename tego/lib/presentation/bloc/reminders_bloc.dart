import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/reminder.dart';

// Events
abstract class RemindersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReminders extends RemindersEvent {}

class AddReminder extends RemindersEvent {
  final Reminder reminder;
  AddReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class UpdateReminder extends RemindersEvent {
  final Reminder reminder;
  UpdateReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class CompleteReminder extends RemindersEvent {
  final String reminderId;
  CompleteReminder(this.reminderId);
  @override
  List<Object?> get props => [reminderId];
}

class DeleteReminder extends RemindersEvent {
  final String reminderId;
  DeleteReminder(this.reminderId);
  @override
  List<Object?> get props => [reminderId];
}

class CheckLowStockReminders extends RemindersEvent {}

// States
abstract class RemindersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RemindersInitial extends RemindersState {}

class RemindersLoading extends RemindersState {}

class RemindersLoaded extends RemindersState {
  final List<Reminder> reminders;
  final int overdueCount;
  final int todayCount;

  RemindersLoaded({
    required this.reminders,
    required this.overdueCount,
    required this.todayCount,
  });

  @override
  List<Object?> get props => [reminders, overdueCount, todayCount];
}

class RemindersError extends RemindersState {
  final String message;
  RemindersError(this.message);
  @override
  List<Object?> get props => [message];
}

class RemindersOperationSuccess extends RemindersState {
  final String message;
  RemindersOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  RemindersBloc() : super(RemindersInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<CompleteReminder>(_onCompleteReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<CheckLowStockReminders>(_onCheckLowStockReminders);
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadReminders(LoadReminders event, Emitter<RemindersState> emit) async {
    emit(RemindersLoading());
    try {
      final snapshot = await FirestoreService.instance.getCollection('users/$_userId/reminders');
      final reminders = snapshot.docs
          .map((doc) => Reminder.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Sort by due date
      reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      final overdueCount = reminders.where((r) => r.isOverdue).length;
      final todayCount = reminders.where((r) => r.isDueToday).length;

      emit(RemindersLoaded(
        reminders: reminders,
        overdueCount: overdueCount,
        todayCount: todayCount,
      ));
    } catch (e) {
      // If collection doesn't exist, return empty state instead of error
      emit(RemindersLoaded(
        reminders: [],
        overdueCount: 0,
        todayCount: 0,
      ));
    }
  }

  Future<void> _onAddReminder(AddReminder event, Emitter<RemindersState> emit) async {
    try {
      await FirestoreService.instance.addDocument(
        'users/$_userId/reminders',
        event.reminder.toMap(),
      );
      emit(RemindersOperationSuccess('Reminder added successfully'));
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError('Failed to add reminder: $e'));
    }
  }

  Future<void> _onUpdateReminder(UpdateReminder event, Emitter<RemindersState> emit) async {
    try {
      await FirestoreService.instance.updateDocumentFields(
        'users/$_userId/reminders',
        event.reminder.id!,
        event.reminder.toMap(),
      );
      emit(RemindersOperationSuccess('Reminder updated successfully'));
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError('Failed to update reminder: $e'));
    }
  }

  Future<void> _onCompleteReminder(CompleteReminder event, Emitter<RemindersState> emit) async {
    try {
      await FirestoreService.instance.updateDocumentFields(
        'users/$_userId/reminders',
        event.reminderId,
        {
          'isCompleted': true,
          'updatedAt': DateTime.now(),
        },
      );
      emit(RemindersOperationSuccess('Reminder completed'));
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError('Failed to complete reminder: $e'));
    }
  }

  Future<void> _onDeleteReminder(DeleteReminder event, Emitter<RemindersState> emit) async {
    try {
      await FirestoreService.instance.deleteDocument(
        'users/$_userId/reminders',
        event.reminderId,
      );
      emit(RemindersOperationSuccess('Reminder deleted successfully'));
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError('Failed to delete reminder: $e'));
    }
  }

  Future<void> _onCheckLowStockReminders(CheckLowStockReminders event, Emitter<RemindersState> emit) async {
    try {
      // Get inventory items with low stock
      final inventorySnapshot = await FirestoreService.instance.getCollection('users/$_userId/inventory');
      final lowStockItems = inventorySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
        final minStock = (data['minStockLevel'] as num?)?.toInt() ?? 5;
        return quantity <= minStock;
      }).toList();

      // Check existing low stock reminders
      final remindersSnapshot = await FirestoreService.instance.getCollection('users/$_userId/reminders');
      final existingLowStockReminders = remindersSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['type'] == 'lowStock' && !(data['isCompleted'] ?? false);
          })
          .map((doc) => (doc.data() as Map<String, dynamic>)['relatedItemId'] as String?)
          .where((id) => id != null)
          .toSet();

      // Create reminders for new low stock items
      for (final doc in lowStockItems) {
        final itemId = doc.id;
        if (!existingLowStockReminders.contains(itemId)) {
          final data = doc.data() as Map<String, dynamic>;
          final itemName = data['name'] ?? 'Unknown Item';
          final quantity = (data['quantity'] as num?)?.toInt() ?? 0;

          final reminder = Reminder(
            title: 'Low Stock Alert',
            description: '$itemName is running low (${quantity} left)',
            type: ReminderType.lowStock,
            priority: ReminderPriority.high,
            dueDate: DateTime.now(),
            relatedItemId: itemId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await FirestoreService.instance.addDocument(
            'users/$_userId/reminders',
            reminder.toMap(),
          );
        }
      }

      add(LoadReminders());
    } catch (e) {
      emit(RemindersError('Failed to check low stock reminders: $e'));
    }
  }
}