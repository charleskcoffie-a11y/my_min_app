import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sermon.dart';

/// Repository for managing sermons in Supabase
class SermonRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all sermons ordered by creation date
  Future<List<Sermon>> getAllSermons() async {
    try {
      final response = await _supabase
          .from('sermons')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Sermon.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sermons: $e');
    }
  }

  /// Insert a new sermon
  Future<Sermon> insertSermon(Sermon sermon) async {
    try {
      final response = await _supabase
          .from('sermons')
          .insert(sermon.toJson())
          .select()
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create sermon: $e');
    }
  }

  /// Update an existing sermon
  Future<Sermon> updateSermon(Sermon sermon) async {
    try {
      final response = await _supabase
          .from('sermons')
          .update(sermon.toJson())
          .eq('id', sermon.id)
          .select()
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update sermon: $e');
    }
  }

  /// Delete a sermon by ID
  Future<void> deleteSermon(String id) async {
    try {
      await _supabase.from('sermons').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete sermon: $e');
    }
  }

  /// Get a sermon by ID
  Future<Sermon?> getSermonById(String id) async {
    try {
      final response = await _supabase
          .from('sermons')
          .select()
          .eq('id', id)
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      print('Error fetching sermon: $e');
      return null;
    }
  }
}
