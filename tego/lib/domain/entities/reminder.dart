import 'package:equatable/equatable.dart';

enum ReminderType {
  lowStock,
  payment,
  expense,
  custom,
}

enum ReminderPriority {
  low,
  medium,
  high,
}

class Reminder extends Equatable {
  final String? id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final bool isRecurring;
  final String? relatedItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.priority = ReminderPriority.medium,
    required this.dueDate,
    this.isCompleted = false,
    this.isRecurring = false,
    this.relatedItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, title, description, type, priority, dueDate,
    isCompleted, isRecurring, relatedItemId, createdAt, updatedAt
  ];

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);
  bool get isDueToday {
    final now = DateTime.now();
    return !isCompleted && 
           dueDate.year == now.year && 
           dueDate.month == now.month && 
           dueDate.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'isRecurring': isRecurring,
      'relatedItemId': relatedItemId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map, String id) {
    return Reminder(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.custom,
      ),
      priority: ReminderPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      dueDate: map['dueDate']?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      isRecurring: map['isRecurring'] ?? false,
      relatedItemId: map['relatedItemId'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Reminder copyWith({
    String? title,
    String? description,
    ReminderType? type,
    ReminderPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isRecurring,
    String? relatedItemId,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}