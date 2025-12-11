import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/standing_order.dart';

/// Repository for managing standing orders in Supabase
class StandingOrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all standing orders
  Future<List<StandingOrder>> getAllOrders({
    String? searchQuery,
    bool? favoritesOnly,
  }) async {
    try {
      var query = _supabase.from('standing_orders').select();

      if (favoritesOnly == true) {
        query = query.eq('is_favorite', true);
      }

      final response = await query.order('code', ascending: true);

      List<StandingOrder> orders = (response as List)
          .map((json) => StandingOrder.fromMap(json as Map<String, dynamic>))
          .toList();

      // Filter by search query client-side
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        orders = orders
            .where((order) =>
                order.code.toLowerCase().contains(query) ||
                order.title.toLowerCase().contains(query) ||
                order.content.toLowerCase().contains(query))
            .toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch standing orders: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _supabase
          .from('standing_orders')
          .update({'is_favorite': isFavorite})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }

  /// Get single order by ID
  Future<StandingOrder?> getOrderById(String id) async {
    try {
      final response =
          await _supabase.from('standing_orders').select().eq('id', id).single();

      return StandingOrder.fromMap(response);
    } catch (e) {
      return null;
    }
  }
}
