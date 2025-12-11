import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/counseling_session.dart';

/// Repository for managing counseling sessions in Supabase
class CounselingSessionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all counseling sessions
  Future<List<CounselingSession>> getAllSessions() async {
    try {
      final response = await _supabase
          .from('counseling_sessions')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CounselingSession.fromMap(json as Map<String, dynamic>))
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
          .insert(session.toMap())
          .select()
          .single();

      return CounselingSession.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create counseling session: $e');
    }
  }

  /// Update an existing counseling session
  Future<CounselingSession> updateSession(CounselingSession session) async {
    try {
      final response = await _supabase
          .from('counseling_sessions')
          .update(session.toMap())
          .eq('id', session.id!)
          .select()
          .single();

      return CounselingSession.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update counseling session: $e');
    }
  }

  /// Delete a counseling session
  Future<void> deleteSession(String id) async {
    try {
      await _supabase.from('counseling_sessions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete counseling session: $e');
    }
  }
}
