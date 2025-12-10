import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/counseling_case.dart';

class CounselingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CounselingCase>> getAllCases() async {
    final response = await _client
        .from('counseling_cases')
        .select()
        .order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list
        .map((row) => CounselingCase.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<CounselingCase>> getCasesByStatus(String status) async {
    final response = await _client
        .from('counseling_cases')
        .select()
        .eq('status', status)
        .order('follow_up_date', ascending: true);

    final list = response as List<dynamic>;
    return list
        .map((row) => CounselingCase.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<CounselingCase?> getCaseById(String id) async {
    final response =
        await _client.from('counseling_cases').select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return CounselingCase.fromMap(response);
  }

  Future<void> createCase({
    required String personInitials,
    required String caseType,
    required String summary,
    required String keyIssues,
    required String scripturesUsed,
    required String actionSteps,
    required String prayerPoints,
    required DateTime followUpDate,
    DateTime? followUpReminder,
    required String notes,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();

    await _client.from('counseling_cases').insert({
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
      'status': 'Open',
      'created_at': DateTime.now().toIso8601String(),
      'notes': notes,
    });

    // Schedule notification if reminder is set
    if (followUpReminder != null) {
      try {
        final notifId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
        await _scheduleReminder(notifId, personInitials, followUpReminder, id);
      } catch (_) {
        // Silently fail notification scheduling
      }
    }
  }

  Future<void> updateCase({
    required String id,
    String? personInitials,
    String? caseType,
    String? summary,
    String? keyIssues,
    String? scripturesUsed,
    String? actionSteps,
    String? prayerPoints,
    DateTime? followUpDate,
    DateTime? followUpReminder,
    String? status,
    String? notes,
  }) async {
    final updateData = <String, dynamic>{};

    if (personInitials != null) updateData['person_initials'] = personInitials;
    if (caseType != null) updateData['case_type'] = caseType;
    if (summary != null) updateData['summary'] = summary;
    if (keyIssues != null) updateData['key_issues'] = keyIssues;
    if (scripturesUsed != null) updateData['scriptures_used'] = scripturesUsed;
    if (actionSteps != null) updateData['action_steps'] = actionSteps;
    if (prayerPoints != null) updateData['prayer_points'] = prayerPoints;
    if (followUpDate != null) updateData['follow_up_date'] = followUpDate.toIso8601String();
    if (followUpReminder != null) updateData['follow_up_reminder'] = followUpReminder.toIso8601String();
    if (status != null) updateData['status'] = status;
    if (notes != null) updateData['notes'] = notes;

    if (updateData.isNotEmpty) {
      await _client.from('counseling_cases').update(updateData).eq('id', id);
    }

    // Reschedule notification if reminder changed
    if (followUpReminder != null) {
      try {
        final notifId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
        await _scheduleReminder(notifId, personInitials ?? '', followUpReminder, id);
      } catch (_) {}
    }
  }

  Future<void> closeCase(String id) async {
    await _client.from('counseling_cases').update({
      'status': 'Closed',
      'closed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteCase(String id) async {
    await _client.from('counseling_cases').delete().eq('id', id);
  }

  // Helper to schedule reminder using NotificationService
  Future<void> _scheduleReminder(int notifId, String personInitials, DateTime when, String caseId) async {
    // Import NotificationService if notifications are needed
    // This is a placeholder; in production, integrate with NotificationService
  }

  Future<List<CounselingCase>> searchCases(String query) async {
    final response = await _client
        .from('counseling_cases')
        .select()
        .or('person_initials.ilike.%$query%,case_type.ilike.%$query%,summary.ilike.%$query%');

    final list = response as List<dynamic>;
    return list
        .map((row) => CounselingCase.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
