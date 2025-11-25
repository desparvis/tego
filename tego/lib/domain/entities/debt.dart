import 'package:equatable/equatable.dart';

enum DebtType { receivable, payable }

class Debt extends Equatable {
  final String? id;
  final String customerName;
  final double amount;
  final DebtType type;
  final String description;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime createdAt;

  const Debt({
    this.id,
    required this.customerName,
    required this.amount,
    required this.type,
    required this.description,
    required this.dueDate,
    this.isPaid = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, customerName, amount, type, description, dueDate, isPaid, createdAt];

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'amount': amount,
      'type': type.name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map, String id) {
    return Debt(
      id: id,
      customerName: map['customerName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: DebtType.values.firstWhere((e) => e.name == map['type'], orElse: () => DebtType.receivable),
      description: map['description'] ?? '',
      dueDate: map['dueDate'] is String ? DateTime.parse(map['dueDate']) : (map['dueDate']?.toDate() ?? DateTime.now()),
      isPaid: map['isPaid'] ?? false,
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : (map['createdAt']?.toDate() ?? DateTime.now()),
    );
  }
}