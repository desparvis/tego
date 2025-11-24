import 'package:equatable/equatable.dart';

/// Domain entity representing a user profile
/// Contains core user data without any external dependencies
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final DateTime? lastSignIn;
  final int totalSalesCount;
  final double totalAmount;
  final int todaySalesCount;
  final DateTime? lastSaleAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.lastSignIn,
    this.totalSalesCount = 0,
    this.totalAmount = 0.0,
    this.todaySalesCount = 0,
    this.lastSaleAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        lastSignIn,
        totalSalesCount,
        totalAmount,
        todaySalesCount,
        lastSaleAt,
      ];

  /// Creates User from Firestore document data
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      lastSignIn: map['lastSignIn']?.toDate(),
      totalSalesCount: (map['totalSalesCount'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      todaySalesCount: (map['todaySalesCount'] as num?)?.toInt() ?? 0,
      lastSaleAt: map['lastSaleAt']?.toDate(),
    );
  }

  /// Converts User to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'lastSignIn': lastSignIn,
      'totalSalesCount': totalSalesCount,
      'totalAmount': totalAmount,
      'todaySalesCount': todaySalesCount,
      'lastSaleAt': lastSaleAt,
    };
  }

  /// Creates a copy with updated fields
  User copyWith({
    String? email,
    String? displayName,
    DateTime? lastSignIn,
    int? totalSalesCount,
    double? totalAmount,
    int? todaySalesCount,
    DateTime? lastSaleAt,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      totalSalesCount: totalSalesCount ?? this.totalSalesCount,
      totalAmount: totalAmount ?? this.totalAmount,
      todaySalesCount: todaySalesCount ?? this.todaySalesCount,
      lastSaleAt: lastSaleAt ?? this.lastSaleAt,
    );
  }
}