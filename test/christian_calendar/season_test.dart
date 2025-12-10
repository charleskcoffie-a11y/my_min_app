import 'package:flutter_test/flutter_test.dart';
import 'package:my_min_app/features/christian_calendar/season.dart';

void main() {
  group('Season calculation', () {
    test('Easter 2025 returns Easter', () {
      final date = DateTime(2025, 4, 20);
      final s = getSeasonForDate(date);
      expect(s.name, 'Easter');
    });

    test('Pentecost 2025 returns Pentecost', () {
      final pentecost = DateTime(2025, 6, 8);
      final s = getSeasonForDate(pentecost);
      expect(s.name, 'Pentecost');
    });

    test('Christmas and New Year return Christmas', () {
      expect(getSeasonForDate(DateTime(2025, 12, 25)).name, 'Christmas');
      expect(getSeasonForDate(DateTime(2026, 1, 1)).name, 'Christmas');
    });

    test('Epiphany Jan 6 returns Epiphany', () {
      expect(getSeasonForDate(DateTime(2025, 1, 6)).name, 'Epiphany');
    });

    test('Lent returns Lent for a mid-Lent date', () {
      // For 2025, Lent should include March 20
      expect(getSeasonForDate(DateTime(2025, 3, 20)).name, 'Lent');
    });

    test('Palm Sunday / Holy Week returns Holy Week', () {
      expect(getSeasonForDate(DateTime(2025, 4, 13)).name, 'Holy Week');
    });

    test('Ordinary Time returns Ordinary Time for July date', () {
      expect(getSeasonForDate(DateTime(2025, 7, 1)).name, 'Ordinary Time');
    });

    test('Advent returns Advent for mid-December before Christmas', () {
      expect(getSeasonForDate(DateTime(2025, 12, 15)).name, 'Advent');
    });
  });
}
