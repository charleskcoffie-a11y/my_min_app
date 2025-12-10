import 'package:flutter/foundation.dart';

/// Generic cache manager for repositories
class CacheManager<T> {
  final Map<String, _CacheEntry<T>> _cache = {};
  final Duration _defaultDuration;

  CacheManager({Duration defaultDuration = const Duration(minutes: 5)})
      : _defaultDuration = defaultDuration;

  /// Get cached value if available and not expired
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  /// Set value in cache
  void set(String key, T value, {Duration? duration}) {
    _cache[key] = _CacheEntry(
      value,
      DateTime.now().add(duration ?? _defaultDuration),
    );
  }

  /// Clear specific cache entry
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Get or compute value - returns cached if available, otherwise computes and caches
  Future<T> getOrCompute(
    String key,
    Future<T> Function() compute, {
    Duration? duration,
  }) async {
    final cached = get(key);
    if (cached != null) {
      debugPrint('✅ Cache hit for key: $key');
      return cached;
    }

    debugPrint('⚠️ Cache miss for key: $key, computing...');
    final result = await compute();
    set(key, result, duration: duration);
    return result;
  }

  /// Cache size info
  int get size => _cache.length;

  /// Get cache statistics
  String getCacheStats() {
    return 'Cache size: ${_cache.length} entries';
  }
}

/// Internal cache entry class
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);
}
