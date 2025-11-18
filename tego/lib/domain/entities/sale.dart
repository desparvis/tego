/// Domain entity representing a sale transaction
/// Contains core business data without any external dependencies
class Sale {
  final String? id;
  final double amount;
  final String date;
  final DateTime? timestamp;

  const Sale({
    this.id,
    required this.amount,
    required this.date,
    this.timestamp,
  });

  /// Creates Sale from Firestore document data
  factory Sale.fromMap(Map<String, dynamic> map, String id) {
    return Sale(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      timestamp: map['timestamp']?.toDate(),
    );
  }

  /// Converts Sale to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date,
      'timestamp': timestamp,
    };
  }
}