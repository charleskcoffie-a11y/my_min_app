import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_verse.dart';

/// Curated list of verse references for daily rotation
/// Add as many as you like - the app will cycle through them
const List<String> yearlyVerseRefs = [
  'Psalm 1:1-3',
  'Proverbs 3:5-6',
  'John 1:1-5',
  'Philippians 4:6-7',
  'Romans 8:28',
  'Isaiah 40:31',
  'Matthew 5:14-16',
  'Psalm 23:1-4',
  '2 Corinthians 5:17',
  'Jeremiah 29:11',
  'Joshua 1:9',
  'Psalm 46:1',
  'John 3:16',
  'Romans 12:2',
  'Ephesians 2:8-9',
  'Psalm 119:105',
  'Proverbs 18:10',
  'Isaiah 41:10',
  'Matthew 6:33',
  'Philippians 4:13',
  '1 John 4:19',
  'Psalm 27:1',
  'John 14:6',
  'Romans 6:23',
  'Hebrews 11:1',
  '1 Corinthians 10:13',
  'Psalm 34:8',
  'John 15:5',
  'Galatians 5:22-23',
  'Matthew 11:28-30',
];

/// Repository for managing daily verses from Supabase
class DailyVerseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Starting date for verse rotation
  static final DateTime startDate = DateTime(2025, 1, 1);

  /// Get today's verse reference based on day rotation
  String getTodaysVerseReference() {
    final today = DateTime.now();
    final daysSinceStart = today.difference(startDate).inDays;
    final index = daysSinceStart % yearlyVerseRefs.length;
    return yearlyVerseRefs[index];
  }

  /// Get verse for today using rotation system
  Future<DailyVerse?> getVerseForToday() async {
    try {
      // Get today's reference from rotation
      final reference = getTodaysVerseReference();
      
      // Try to fetch from Supabase by reference
      final response = await _supabase
          .from('daily_verses')
          .select()
          .eq('reference', reference)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return DailyVerse.fromMap(response as Map<String, dynamic>);
      }
      
      // Fallback: get any verse with similar reference (case-insensitive)
      final similarResponse = await _supabase
          .from('daily_verses')
          .select()
          .ilike('reference', '%${reference.split(':')[0]}%')
          .limit(1)
          .maybeSingle();
          
      if (similarResponse != null) {
        return DailyVerse.fromMap(similarResponse);
      }
    } catch (e) {
      print('Error fetching verse by reference: $e');
    }

    // Final fallback: get the most recent verse
    try {
      final response = await _supabase
          .from('daily_verses')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return DailyVerse.fromMap(response as Map<String, dynamic>);
      }
    } catch (e) {
      print('Failed to fetch fallback verse: $e');
    }

    return null;
  }

  /// Get a random verse
  Future<DailyVerse?> getRandomVerse() async {
    try {
      final response = await _supabase
          .from('daily_verses')
          .select()
          .limit(1)
          .single();

      return DailyVerse.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch random verse: $e');
    }
  }

  /// Get upcoming verses for the next N days
  Future<List<DailyVerse>> getUpcomingVerses({int days = 7}) async {
    try {
      final today = DateTime.now();
      final endDate = today.add(Duration(days: days));

      final response = await _supabase
          .from('daily_verses')
          .select()
          .gte('date', today.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: true);

      return (response as List)
          .map((json) => DailyVerse.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming verses: $e');
    }
  }

  /// Get verse by ID
  Future<DailyVerse?> getVerseById(String id) async {
    try {
      final response = await _supabase
          .from('daily_verses')
          .select()
          .eq('id', id)
          .limit(1)
          .single();

      return DailyVerse.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch verse by ID: $e');
    }
  }

  /// Insert a new verse (admin function)
  Future<DailyVerse> insertVerse(DailyVerse verse) async {
    try {
      final response = await _supabase
          .from('daily_verses')
          .insert(verse.toMap())
          .select()
          .single();

      return DailyVerse.fromMap(response);
    } catch (e) {
      throw Exception('Failed to insert verse: $e');
    }
  }
}
