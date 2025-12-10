import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String title;
  final String eventType; // 'Preaching', 'Meeting', 'Counseling', 'Visitation', 'Study', 'Off Day'
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? notes;
  final bool isAllDay;
  final bool isRecurring; // For future recurring appointments
  final String? recurrencePattern; // 'weekly', 'monthly', etc.
  final String? attendees; // Comma-separated names or emails
  final String reminderType; // 'none', '15min', '30min', '1hour', '1day'
  final int? notificationId; // For notification tracking
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.title,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    this.location,
    this.notes,
    this.isAllDay = false,
    this.isRecurring = false,
    this.recurrencePattern,
    this.attendees,
    this.reminderType = '15min',
    this.notificationId,
    required this.createdAt,
    this.updatedAt,
  });

  // Get duration of appointment
  Duration get duration => endTime.difference(startTime);

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  // Check if appointment is upcoming (in the future)
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  // Check if appointment is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  // Check if appointment has passed
  bool get isPast => endTime.isBefore(DateTime.now());

  // Get appointment time display (formatted)
  String get timeDisplay {
    if (isAllDay) {
      return 'All Day';
    }
    final startStr = DateFormat('h:mm a').format(startTime);
    final endStr = DateFormat('h:mm a').format(endTime);
    return '$startStr - $endStr';
  }

  // Get appointment date display (formatted)
  String get dateDisplay => DateFormat('EEE, MMM d, yyyy').format(startTime);

  // Get color based on event type
  String get eventColor {
    switch (eventType) {
      case 'Preaching':
        return '#FF6B6B'; // Red
      case 'Meeting':
        return '#4ECDC4'; // Teal
      case 'Counseling':
        return '#45B7D1'; // Blue
      case 'Visitation':
        return '#FFA07A'; // Orange
      case 'Study':
        return '#9B59B6'; // Purple
      case 'Off Day':
        return '#95E1D3'; // Light Green
      default:
        return '#95A5A6'; // Gray
    }
  }

  // Serialize to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'event_type': eventType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'notes': notes,
      'is_all_day': isAllDay,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'attendees': attendees,
      'reminder_type': reminderType,
      'notification_id': notificationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Deserialize from Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      title: map['title'] as String,
      eventType: map['event_type'] as String? ?? 'Meeting',
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      isAllDay: map['is_all_day'] as bool? ?? false,
      isRecurring: map['is_recurring'] as bool? ?? false,
      recurrencePattern: map['recurrence_pattern'] as String?,
      attendees: map['attendees'] as String?,
      reminderType: map['reminder_type'] as String? ?? '15min',
      notificationId: map['notification_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  // Create a copy with modified fields
  Appointment copyWith({
    String? id,
    String? title,
    String? eventType,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? notes,
    bool? isAllDay,
    bool? isRecurring,
    String? recurrencePattern,
    String? attendees,
    String? reminderType,
    int? notificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      eventType: eventType ?? this.eventType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isAllDay: isAllDay ?? this.isAllDay,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      attendees: attendees ?? this.attendees,
      reminderType: reminderType ?? this.reminderType,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
