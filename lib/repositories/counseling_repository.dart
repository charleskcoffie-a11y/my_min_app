import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/counseling_session.dart';

/// Repository for managing counseling sessions in Supabase
class CounselingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all counseling sessions ordered by created_at descending
  Future<List<CounselingSession>> getAllSessions() async {
    try {
      final response = await _supabase
          .from('counseling_sessions')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CounselingSession.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch counseling sessions: $e');
    }
  }

  /// Insert a new counseling session
  Future<CounselingSession> insertSession(CounselingSession session) async {
    try {
      final response = await _supabase
          .from('counseling_sessions')
          .insert(session.toJson())
          .select()
          .single();

      return CounselingSession.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create counseling session: $e');
    }
  }

  /// Update an existing counseling session
  Future<CounselingSession> updateSession(
    String id,
    CounselingSession session,
  ) async {
    try {
      final response = await _supabase
          .from('counseling_sessions')
          .update(session.toJson())
          .eq('id', id)
          .select()
          .single();

      return CounselingSession.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update counseling session: $e');
    }
  }

  /// Delete a counseling session by ID
  Future<void> deleteSession(String id) async {
    try {
      await _supabase.from('counseling_sessions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete counseling session: $e');
    }
  }

  /// Create a reminder for follow-up
  Future<void> createReminder({
    required String initials,
    required String caseType,
    required DateTime followUpDate,
  }) async {
    try {
      await _supabase.from('reminders').insert({
        'title': 'Counseling Follow-up: $initials',
        'category': 'Counseling',
        'frequency': 'One-time',
        'start_date': followUpDate.toIso8601String(),
        'notes': 'Follow up on case regarding $caseType.',
        'is_active': true,
      });
    } catch (e) {
      throw Exception('Failed to create reminder: $e');
    }
  }
}
