import 'package:supabase_flutter/supabase_flutter.dart';

class SermonRepository {
  final SupabaseClient client = Supabase.instance.client;

  /// Save sermon as a row in `sermons` table. Table might not exist in project.
  Future<void> saveSermon(Map<String, dynamic> sermon) async {
    try {
      await client.from('sermons').insert(sermon);
    } catch (e) {
      // If Supabase table doesn't exist or insert fails, we still want the app to work.
      // In production you'd surface the error to the user or create the table via migration.
      throw Exception('Failed to save sermon: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSermons() async {
    try {
      final res = await client.from('sermons').select();
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      return [];
    }
  }
}
