import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String? id;
  final String name;
  final double stockCost;
  final double intendedProfit;
  final int quantity;
  final DateTime createdAt;

  const InventoryItem({
    this.id,
    required this.name,
    required this.stockCost,
    required this.intendedProfit,
    required this.quantity,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, stockCost, intendedProfit, quantity, createdAt];

  double get sellingPrice => stockCost + intendedProfit;
  double get totalStockValue => quantity * stockCost;
  double get totalIntendedProfit => quantity * intendedProfit;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stockCost': stockCost,
      'intendedProfit': intendedProfit,
      'quantity': quantity,
      'createdAt': createdAt,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItem(
      id: id,
      name: map['name'] ?? '',
      stockCost: (map['stockCost'] as num?)?.toDouble() ?? 0.0,
      intendedProfit: (map['intendedProfit'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}