import 'package:intl/intl.dart';

class Task {
  final String id;
  final String? title;
  final String category;
  final String? description;
  final DateTime taskDate;
  final String priority;
  final String status;
  final String? message;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    this.title,
    this.category = 'Other',
    this.description,
    required this.taskDate,
    this.priority = 'Medium',
    this.status = 'Pending',
    this.message,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.parse(value as String);
    }

    return Task(
      id: map['id'] as String,
      title: map['title'] as String?,
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String?,
      taskDate: parseDate(map['task_date']),
      priority: map['priority'] as String? ?? 'Medium',
      status: map['status'] as String? ?? 'Pending',
      message: map['message'] as String?,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt:
          map['completed_at'] != null ? parseDate(map['completed_at']) : null,
      createdAt: parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'task_date': formatDate(taskDate),
      'priority': priority,
      'status': status,
      'message': message,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
