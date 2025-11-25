import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../../domain/entities/inventory_item.dart';


// Events
abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final InventoryItem item;
  AddInventoryItem(this.item);
  @override
  List<Object?> get props => [item];
}

class UpdateInventoryItem extends InventoryEvent {
  final InventoryItem item;
  UpdateInventoryItem(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteInventoryItem extends InventoryEvent {
  final String itemId;
  DeleteInventoryItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class UpdateStock extends InventoryEvent {
  final String itemId;
  final int newQuantity;
  UpdateStock(this.itemId, this.newQuantity);
  @override
  List<Object?> get props => [itemId, newQuantity];
}

// States
abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  final double totalStockCost;
  final double totalIntendedProfit;

  InventoryLoaded({
    required this.items,
    required this.totalStockCost,
    required this.totalIntendedProfit,
  });

  @override
  List<Object?> get props => [items, totalStockCost, totalIntendedProfit];
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class InventoryOperationSuccess extends InventoryState {
  final String message;
  InventoryOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventoryItem>(_onAddInventoryItem);
    on<UpdateInventoryItem>(_onUpdateInventoryItem);
    on<DeleteInventoryItem>(_onDeleteInventoryItem);
    on<UpdateStock>(_onUpdateStock);
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadInventory(LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final snapshot = await FirestoreService.instance.getCollection('users/$_userId/inventory');
      final items = snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final totalStockCost = items.fold<double>(0, (sum, item) => sum + item.totalStockValue);
      final totalIntendedProfit = items.fold<double>(0, (sum, item) => sum + item.totalIntendedProfit);

      emit(InventoryLoaded(
        items: items,
        totalStockCost: totalStockCost,
        totalIntendedProfit: totalIntendedProfit,
      ));
    } catch (e) {
      // If collection doesn't exist, return empty state instead of error
      emit(InventoryLoaded(
        items: [],
        totalStockCost: 0.0,
        totalIntendedProfit: 0.0,
      ));
    }
  }

  Future<void> _onAddInventoryItem(AddInventoryItem event, Emitter<InventoryState> emit) async {
    try {
      await FirestoreService.instance.addDocument(
        'users/$_userId/inventory',
        event.item.toMap(),
      );
      emit(InventoryOperationSuccess('Item added successfully'));
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError('Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateInventoryItem(UpdateInventoryItem event, Emitter<InventoryState> emit) async {
    try {
      await FirestoreService.instance.updateDocumentFields(
        'users/$_userId/inventory',
        event.item.id!,
        event.item.toMap(),
      );
      emit(InventoryOperationSuccess('Item updated successfully'));
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError('Failed to update item: $e'));
    }
  }

  Future<void> _onDeleteInventoryItem(DeleteInventoryItem event, Emitter<InventoryState> emit) async {
    try {
      await FirestoreService.instance.deleteDocument(
        'users/$_userId/inventory',
        event.itemId,
      );
      emit(InventoryOperationSuccess('Item deleted successfully'));
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError('Failed to delete item: $e'));
    }
  }

  Future<void> _onUpdateStock(UpdateStock event, Emitter<InventoryState> emit) async {
    try {
      await FirestoreService.instance.updateDocumentFields(
        'users/$_userId/inventory',
        event.itemId,
        {
          'quantity': event.newQuantity,
          'updatedAt': DateTime.now(),
        },
      );
      emit(InventoryOperationSuccess('Stock updated successfully'));
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError('Failed to update stock: $e'));
    }
  }


}