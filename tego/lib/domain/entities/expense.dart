import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String? id;
  final double amount;
  final String category;
  final String description;
  final String date;
  final DateTime timestamp;

  const Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, amount, category, description, date, timestamp];

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'timestamp': timestamp,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}