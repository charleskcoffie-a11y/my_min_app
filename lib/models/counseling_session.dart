/// Model for counseling sessions stored in Supabase
class CounselingSession {
  final String id;
  final String initials;
  final String caseType;
  final String summary;
  final String? keyIssues;
  final String? scripturesUsed;
  final String? actionSteps;
  final String? prayerPoints;
  final DateTime? followUpDate;
  final String status;
  final DateTime createdAt;

  CounselingSession({
    required this.id,
    required this.initials,
    required this.caseType,
    required this.summary,
    this.keyIssues,
    this.scripturesUsed,
    this.actionSteps,
    this.prayerPoints,
    this.followUpDate,
    required this.status,
    required this.createdAt,
  });

  /// Create from Supabase JSON
  factory CounselingSession.fromJson(Map<String, dynamic> json) {
    return CounselingSession(
      id: json['id'] as String,
      initials: json['initials'] as String,
      caseType: json['case_type'] as String,
      summary: json['summary'] as String? ?? '',
      keyIssues: json['key_issues'] as String?,
      scripturesUsed: json['scriptures_used'] as String?,
      actionSteps: json['action_steps'] as String?,
      prayerPoints: json['prayer_points'] as String?,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'] as String)
          : null,
      status: json['status'] as String? ?? 'Open',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Create from map (alias for fromJson)
  factory CounselingSession.fromMap(Map<String, dynamic> map) =>
      CounselingSession.fromJson(map);

  /// Convert to Supabase JSON for insert/update
  Map<String, dynamic> toJson() {
    return {
      'initials': initials,
      'case_type': caseType,
      'summary': summary,
      'key_issues': keyIssues,
      'scriptures_used': scripturesUsed,
      'action_steps': actionSteps,
      'prayer_points': prayerPoints,
      'follow_up_date': followUpDate?.toIso8601String(),
      'status': status,
    };
  }

  /// Convert to map (alias for toJson)
  Map<String, dynamic> toMap() => toJson();

  /// Copy with method for updates
  CounselingSession copyWith({
    String? id,
    String? initials,
    String? caseType,
    String? summary,
    String? keyIssues,
    String? scripturesUsed,
    String? actionSteps,
    String? prayerPoints,
    DateTime? followUpDate,
    String? status,
    DateTime? createdAt,
  }) {
    return CounselingSession(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      caseType: caseType ?? this.caseType,
      summary: summary ?? this.summary,
      keyIssues: keyIssues ?? this.keyIssues,
      scripturesUsed: scripturesUsed ?? this.scripturesUsed,
      actionSteps: actionSteps ?? this.actionSteps,
      prayerPoints: prayerPoints ?? this.prayerPoints,
      followUpDate: followUpDate ?? this.followUpDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if follow-up is overdue
  bool get isFollowUpOverdue {
    if (followUpDate == null || status == 'Closed') return false;
    return DateTime.now().isAfter(followUpDate!);
  }
}

/// Constants for case types and statuses
class CounselingConstants {
  static const List<String> caseTypes = [
    'Marriage',
    'Family',
    'Addiction',
    'Youth',
    'Bereavement',
    'Spiritual',
    'Other',
  ];

  static const List<String> statuses = [
    'Open',
    'In Progress',
    'Closed',
  ];

  static const String masterCode = '1234'; // Change this for production
}
