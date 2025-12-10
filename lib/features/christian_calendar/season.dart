import 'package:flutter/material.dart';

class Season {
  final String name;
  final Color color;
  final String explanation;
  final String? vestmentSuggestion;
  final DateTime startDate;
  final DateTime endDate;
  final String lectionaryYear; // A, B, or C for the current liturgical year

  Season({
    required this.name,
    required this.color,
    required this.explanation,
    this.vestmentSuggestion,
    required this.startDate,
    required this.endDate,
    required this.lectionaryYear,
  });
}

// Helper: compute Western (Gregorian) Easter for a given year
DateTime _easterDate(int year) {
  // Anonymous Gregorian algorithm
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31; // 3=March, 4=April
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

// Public helper to get the Easter date for a liturgical year start.
DateTime getEasterForLiturgicalYear(int liturgicalYearStart) {
  return _easterDate(liturgicalYearStart + 1);
}

// Find the Sunday on or before the given date
DateTime _sundayOnOrBefore(DateTime date) {
  final dow = date.weekday; // 1=Mon ... 7=Sun
  final daysBack = dow % 7; // 0 if Sunday
  return date.subtract(Duration(days: daysBack));
}

// Get the liturgical season for a given date (Methodist-friendly mapping).
// Returns Season with start/end dates and the lectionary year (A/B/C) for the
// liturgical year that contains the given date.
Season getSeasonForDate(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);

  // Determine liturgical year start (first Sunday of Advent)
  DateTime firstSundayOfAdvent(int year) {
    final dec3 = DateTime(year, 12, 3);
    return _sundayOnOrBefore(dec3);
  }

  final adventThisYear = firstSundayOfAdvent(d.year);
  final liturgicalYearStart = d.isAtSameMomentAs(adventThisYear) || d.isAfter(adventThisYear) ? d.year : d.year - 1;
  final adventStart = firstSundayOfAdvent(liturgicalYearStart);

  // Lectionary year: map liturgicalYearStart modulo 3 to A/B/C
  final mod = liturgicalYearStart % 3;
  final lectionaryYear = mod == 0 ? 'A' : (mod == 1 ? 'B' : 'C');

  // Easter and related dates belong to the calendar year after the liturgical start
  final easter = _easterDate(liturgicalYearStart + 1);
  final ashWednesday = easter.subtract(const Duration(days: 46));
  final palmSunday = easter.subtract(const Duration(days: 7));
  final holySaturday = easter.subtract(const Duration(days: 1));
  final pentecost = easter.add(const Duration(days: 49));
  final ascension = easter.add(const Duration(days: 39));

  // Christmas season for the liturgical year
  final christmasStart = DateTime(liturgicalYearStart, 12, 25);
  final christmasEnd = DateTime(liturgicalYearStart + 1, 1, 5);

  // Epiphany range
  final epiphanyStart = DateTime(liturgicalYearStart + 1, 1, 6);
  final epiphanyEnd = ashWednesday.subtract(const Duration(days: 1));

  // Lent
  final lentStart = ashWednesday;
  final lentEnd = palmSunday.subtract(const Duration(days: 1));

  // Holy Week
  final holyWeekStart = palmSunday;
  final holyWeekEnd = holySaturday;

  // Easter season
  final easterStart = easter;
  final easterEnd = pentecost.subtract(const Duration(days: 1));

  // Pentecost (single day)
  final pentecostStart = pentecost;
  final pentecostEnd = pentecost;

  // Ascension Day (single day)
  final ascensionStart = ascension;
  final ascensionEnd = ascension;

  // All Saints' Day
  final allSaints = DateTime(d.year, 11, 1);

  // Advent range
  final adventEnd = DateTime(liturgicalYearStart, 12, 24);

  // Ordinary Time: from after Baptism/Epiphany season until Lent, and from after Pentecost until Christ the King (Sunday before Advent)
  // For simplicity here we define Ordinary Time as any date not matched by special seasons below.

  // Check ranges in priority order
  if (!d.isBefore(adventStart) && d.isBefore(adventEnd.add(const Duration(days: 1)))) {
    return Season(
      name: 'Advent',
      color: const Color(0xFF4A148C),
      explanation: 'A season of waiting and preparation for the coming of Christ.',
      vestmentSuggestion: 'Purple or blue stole and chasuble',
      startDate: adventStart,
      endDate: adventEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (!d.isBefore(christmasStart) && d.isBefore(christmasEnd.add(const Duration(days: 1)))) {
    return Season(
      name: 'Christmas',
      color: const Color(0xFFFFF9C4),
      explanation: 'Celebration of the birth of Jesus Christ and the Incarnation.',
      vestmentSuggestion: 'White or gold vestments',
      startDate: christmasStart,
      endDate: christmasEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (!d.isBefore(epiphanyStart) && !d.isAfter(epiphanyEnd)) {
    return Season(
      name: 'Epiphany',
      color: const Color(0xFF2E7D32),
      explanation: 'A season reflecting on the revelation of Christ to the nations and his early ministry.',
      vestmentSuggestion: 'Green vestments',
      startDate: epiphanyStart,
      endDate: epiphanyEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (!d.isBefore(lentStart) && !d.isAfter(lentEnd)) {
    return Season(
      name: 'Lent',
      color: const Color(0xFF6A1B9A),
      explanation: 'A penitential season of reflection and preparation for Easter.',
      vestmentSuggestion: 'Purple vestments',
      startDate: lentStart,
      endDate: lentEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (!d.isBefore(holyWeekStart) && !d.isAfter(holyWeekEnd)) {
    return Season(
      name: 'Holy Week',
      color: const Color(0xFFD32F2F),
      explanation: 'The week of Christ’s passion, death, and resurrection.',
      vestmentSuggestion: 'Red or black for Good Friday',
      startDate: holyWeekStart,
      endDate: holyWeekEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (!d.isBefore(easterStart) && !d.isAfter(easterEnd)) {
    return Season(
      name: 'Easter',
      color: const Color(0xFFFFF176),
      explanation: 'A season celebrating the resurrection of Jesus Christ.',
      vestmentSuggestion: 'White or gold vestments',
      startDate: easterStart,
      endDate: easterEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (d.year == pentecost.year && d.month == pentecost.month && d.day == pentecost.day) {
    return Season(
      name: 'Pentecost',
      color: const Color(0xFFD32F2F),
      explanation: 'Commemoration of the gift of the Holy Spirit to the Church.',
      vestmentSuggestion: 'Red vestments',
      startDate: pentecostStart,
      endDate: pentecostEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (d.year == ascension.year && d.month == ascension.month && d.day == ascension.day) {
    return Season(
      name: 'Ascension',
      color: const Color(0xFFD32F2F),
      explanation: 'Celebration of Christ’s ascension into heaven (40 days after Easter).',
      vestmentSuggestion: 'White or red vestments',
      startDate: ascensionStart,
      endDate: ascensionEnd,
      lectionaryYear: lectionaryYear,
    );
  }

  if (d.year == allSaints.year && d.month == allSaints.month && d.day == allSaints.day) {
    return Season(
      name: 'All Saints',
      color: const Color(0xFFFFF9C4),
      explanation: 'A day to remember all the saints and martyrs of the church.',
      vestmentSuggestion: 'White or gold vestments',
      startDate: allSaints,
      endDate: allSaints,
      lectionaryYear: lectionaryYear,
    );
  }

  // Default: Ordinary Time (we return a broad range placeholder)
  // Ordinary Time here is defined from the day after Pentecost to the day before Advent start
  final ordinaryStart = pentecost.add(const Duration(days: 1));
  final ordinaryEnd = adventStart.subtract(const Duration(days: 1));
  return Season(
    name: 'Ordinary Time',
    color: const Color(0xFF2E7D32),
    explanation: 'A time for growth in discipleship and Christian formation.',
    vestmentSuggestion: 'Green vestments',
    startDate: ordinaryStart,
    endDate: ordinaryEnd,
    lectionaryYear: lectionaryYear,
  );
}
