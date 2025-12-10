import 'package:intl/intl.dart';

class CounselingCase {
  final String id;
  final String personInitials; // e.g., "J.S." — for privacy
  final String caseType; // marriage, family, addiction, youth, bereavement, spiritual, other
  final String summary; // Short overview of the situation
  final String keyIssues; // Main concerns and challenges
  final String scripturesUsed; // Relevant Bible passages discussed
  final String actionSteps; // Planned interventions and recommendations
  final String prayerPoints; // Key prayer focuses
  final DateTime followUpDate; // When to follow up with the person
  final DateTime? followUpReminder; // Optional reminder time for follow-up
  final String status; // Open, In Progress, Closed
  final DateTime createdAt;
  final DateTime? closedAt;
  final String notes; // Additional private notes

  CounselingCase({
    required this.id,
    required this.personInitials,
    required this.caseType,
    required this.summary,
    required this.keyIssues,
    required this.scripturesUsed,
    required this.actionSteps,
    required this.prayerPoints,
    required this.followUpDate,
    this.followUpReminder,
    required this.status,
    required this.createdAt,
    this.closedAt,
    required this.notes,
  });

  factory CounselingCase.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.parse(value as String);
    }

    return CounselingCase(
      id: map['id'] as String,
      personInitials: map['person_initials'] as String? ?? '',
      caseType: map['case_type'] as String? ?? 'Other',
      summary: map['summary'] as String? ?? '',
      keyIssues: map['key_issues'] as String? ?? '',
      scripturesUsed: map['scriptures_used'] as String? ?? '',
      actionSteps: map['action_steps'] as String? ?? '',
      prayerPoints: map['prayer_points'] as String? ?? '',
      followUpDate: parseDate(map['follow_up_date']),
      followUpReminder: map['follow_up_reminder'] != null ? parseDate(map['follow_up_reminder']) : null,
      status: map['status'] as String? ?? 'Open',
      createdAt: parseDate(map['created_at']),
      closedAt: map['closed_at'] != null ? parseDate(map['closed_at']) : null,
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_initials': personInitials,
      'case_type': caseType,
      'summary': summary,
      'key_issues': keyIssues,
      'scriptures_used': scripturesUsed,
      'action_steps': actionSteps,
      'prayer_points': prayerPoints,
      'follow_up_date': followUpDate.toIso8601String(),
      'follow_up_reminder': followUpReminder?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  String get displayDate => DateFormat.yMMMd().format(createdAt);
  String get followUpDateDisplay => DateFormat.yMMMd().format(followUpDate);

  bool get isOpen => status == 'Open';
  bool get isInProgress => status == 'In Progress';
  bool get isClosed => status == 'Closed';
}
