import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/song.dart';

/// Repository for managing songs data from Supabase
class SongsRepository {
  final supabase = Supabase.instance.client;

  /// Fetch songs based on collection filters
  Future<List<Song>> getSongsByCollections(
    List<String> collections, {
    String sortBy = 'number',
  }) async {
    try {
      var query = supabase.from('songs').select('*');

      if (collections.isNotEmpty) {
        query = query.inFilter('collection', collections);
      }

      // Chain order directly and await
      final response = await query.order(sortBy, ascending: true);
      return (response as List).map((e) => Song.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  /// Get favorite songs
  Future<List<Song>> getFavoriteSongs({String sortBy = 'number'}) async {
    try {
      final data = await supabase
          .from('songs')
          .select('*')
          .eq('is_favorite', true)
          .order(sortBy, ascending: true);

      return (data as List).map((e) => Song.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error loading favorites: $e');
    }
  }

  /// Get all songs
  Future<List<Song>> getAllSongs({String sortBy = 'number'}) async {
    try {
      final data = await supabase.from('songs').select('*').order(sortBy, ascending: true);

      return (data as List).map((e) => Song.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error loading all songs: $e');
    }
  }

  /// Update song favorite status
  Future<void> toggleFavorite(int songId, bool newStatus) async {
    try {
      await supabase.from('songs').update({'is_favorite': newStatus}).eq('id', songId);
    } catch (e) {
      throw Exception('Error updating favorite: $e');
    }
  }

  /// Seed database with sample songs
  Future<void> seedSampleSongs() async {
    try {
      final sampleSongs = [
        {
          'collection': 'MHB',
          'code': 'MHB1',
          'number': 1,
          'title': 'God the Omnipotent! King',
          'lyrics': 'God the omnipotent! King, whom the voice of nations praise,\nFrom thy single throne beside thee, hear our fervent prayer and praise.\nScatter darkness; bid the light of righteousness and truth prevail.',
          'author': 'Henry Wordsworth',
          'copyright': 'Public Domain',
          'is_favorite': false,
        },
        {
          'collection': 'CANTICLES_EN',
          'code': 'CANT1',
          'number': 1,
          'title': 'Magnificat',
          'lyrics': 'My soul doth magnify the Lord:\nAnd my spirit hath rejoiced in God my Saviour.\nFor he hath regarded:\nThe lowliness of his handmaiden.',
          'author': 'Luke 1:46-55',
          'copyright': 'Public Domain',
          'is_favorite': false,
        },
        {
          'collection': 'CAN',
          'code': 'CAN1',
          'number': 1,
          'title': 'Lead, Kindly Light',
          'lyrics': 'Lead, kindly Light, amid the encircling gloom,\nLead thou me on!\nThe night is dark, and I am far from home;\nLead thou me on!',
          'author': 'John Henry Newman',
          'copyright': 'Public Domain',
          'is_favorite': false,
        },
      ];

      for (final song in sampleSongs) {
        await supabase.from('songs').upsert(
          song,
          onConflict: 'code',
        );
      }
    } catch (e) {
      throw Exception('Error seeding sample songs: $e');
    }
  }
}
