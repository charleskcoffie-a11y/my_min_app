/// Reminder model for pastoral reminders
class Reminder {
  final String? id;
  final String title;
  final String category;
  final String frequency;
  final DateTime startDate;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;

  Reminder({
    this.id,
    required this.title,
    required this.category,
    required this.frequency,
    required this.startDate,
    this.notes,
    this.isActive = true,
    this.createdAt,
  });

  /// Create from Supabase JSON
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Personal Devotion',
      frequency: map['frequency'] as String? ?? 'One-time',
      startDate: DateTime.parse(map['start_date'] as String),
      notes: map['notes'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Convert to Supabase JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'notes': notes,
      'is_active': isActive,
    };
  }

  /// Copy with method
  Reminder copyWith({
    String? id,
    String? title,
    String? category,
    String? frequency,
    DateTime? startDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
