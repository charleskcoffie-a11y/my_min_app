import 'package:flutter_test/flutter_test.dart';
import 'package:my_min_app/core/cache_manager.dart';

void main() {
  group('CacheManager Tests', () {
    late CacheManager<String> cacheManager;

    setUp(() {
      cacheManager = CacheManager<String>(
        defaultDuration: const Duration(seconds: 10),
      );
    });

    test('Get returns null for non-existent key', () {
      expect(cacheManager.get('key1'), isNull);
    });

    test('Set and get returns cached value', () {
      cacheManager.set('key1', 'value1');
      expect(cacheManager.get('key1'), equals('value1'));
    });

    test('Invalidate removes cache entry', () {
      cacheManager.set('key1', 'value1');
      expect(cacheManager.get('key1'), equals('value1'));
      cacheManager.invalidate('key1');
      expect(cacheManager.get('key1'), isNull);
    });

    test('Clear removes all cache entries', () {
      cacheManager.set('key1', 'value1');
      cacheManager.set('key2', 'value2');
      cacheManager.clear();
      expect(cacheManager.size, equals(0));
    });

    test('getOrCompute returns cached value if available', () async {
      cacheManager.set('key1', 'cached');
      int computeCount = 0;

      final result = await cacheManager.getOrCompute('key1', () async {
        computeCount++;
        return 'computed';
      });

      expect(result, equals('cached'));
      expect(computeCount, equals(0));
    });

    test('getOrCompute computes and caches if not available', () async {
      int computeCount = 0;

      final result = await cacheManager.getOrCompute('key1', () async {
        computeCount++;
        return 'computed';
      });

      expect(result, equals('computed'));
      expect(computeCount, equals(1));
      expect(cacheManager.get('key1'), equals('computed'));
    });

    test('Cache size returns correct count', () {
      cacheManager.set('key1', 'value1');
      cacheManager.set('key2', 'value2');
      cacheManager.set('key3', 'value3');
      expect(cacheManager.size, equals(3));
    });
  });
}
