import 'package:flutter/material.dart';
import 'christian_calendar_banner.dart';

class _SeasonData {
  final String id;
  final String name;
  final String cycle;
  final String primaryColour;
  final String? altColour;
  final String summary;
  final String startHint;
  const _SeasonData({
    required this.id,
    required this.name,
    required this.cycle,
    required this.primaryColour,
    this.altColour,
    required this.summary,
    required this.startHint,
  });
}

class _FeastData {
  final String id;
  final String name;
  final String colour;
  final String seasonId;
  final String notes;
  const _FeastData({
    required this.id,
    required this.name,
    required this.colour,
    required this.seasonId,
    required this.notes,
  });
}

const _seasons = [
  _SeasonData(
    id: 'ADVENT',
    name: 'Advent',
    cycle: 'Christmas Cycle',
    primaryColour: 'Violet',
    altColour: 'Blue',
    summary:
        'Four Sundays before Christmas; a season of preparation and expectation for the coming of Christ.',
    startHint: 'Fourth Sunday before 25th December',
  ),
  _SeasonData(
    id: 'CHRISTMAS',
    name: 'Christmas Season',
    cycle: 'Christmas Cycle',
    primaryColour: 'White',
    altColour: 'Gold',
    summary:
        'Celebration of the birth of Christ, beginning on Christmas Eve and continuing for twelve days.',
    startHint: '24/25th December',
  ),
  _SeasonData(
    id: 'EPIPHANY_SEASON',
    name: 'Season after Epiphany',
    cycle: 'Christmas Cycle',
    primaryColour: 'Green',
    summary:
        'Focuses on the revealing of Christ to the nations and His early ministry.',
    startHint: 'From 6th January until the Sunday before Lent',
  ),
  _SeasonData(
    id: 'LENT',
    name: 'Lent',
    cycle: 'Easter Cycle',
    primaryColour: 'Violet',
    summary:
        'Forty days of penitence, self-examination, and preparation for Easter (excluding Sundays).',
    startHint: 'Begins on Ash Wednesday',
  ),
  _SeasonData(
    id: 'HOLY_WEEK',
    name: 'Holy Week',
    cycle: 'Easter Cycle',
    primaryColour: 'Violet',
    altColour: 'Red on some days',
    summary:
        'The week from Palm Sunday to Holy Saturday, recalling Christ’s passion and death.',
    startHint: 'Sunday before Easter (Palm Sunday)',
  ),
  _SeasonData(
    id: 'EASTER_SEASON',
    name: 'Easter Season',
    cycle: 'Easter Cycle',
    primaryColour: 'White',
    altColour: 'Gold',
    summary:
        'Fifty days celebrating the resurrection of Jesus, from Easter Day to Pentecost.',
    startHint: 'Easter Sunday',
  ),
  _SeasonData(
    id: 'PENTECOST_DAY',
    name: 'Day of Pentecost',
    cycle: 'Easter Cycle',
    primaryColour: 'Red',
    summary:
        'Celebrates the outpouring of the Holy Spirit and the birth of the Church.',
    startHint: 'Fiftieth day after Easter',
  ),
  _SeasonData(
    id: 'ORDINARY_TIME',
    name: 'Time after Pentecost / Ordinary Time',
    cycle: 'Ordinary',
    primaryColour: 'Green',
    summary:
        'The long teaching and growth season after Pentecost, sometimes called Kingdomtide in Methodist tradition.',
    startHint: 'From the week after Pentecost until the eve of Advent',
  ),
];

const _feasts = [
  _FeastData(
    id: 'EPIPHANY',
    name: 'Epiphany of the Lord',
    colour: 'White',
    seasonId: 'EPIPHANY_SEASON',
    notes:
        'Celebrates Christ revealed to the Gentiles; commemorated on or around 6th January.',
  ),
  _FeastData(
    id: 'ASH_WEDNESDAY',
    name: 'Ash Wednesday',
    colour: 'Violet',
    seasonId: 'LENT',
    notes: 'Beginning of Lent; emphasis on repentance and mortality.',
  ),
  _FeastData(
    id: 'PALM_SUNDAY',
    name: 'Palm/Passion Sunday',
    colour: 'Violet / Red',
    seasonId: 'HOLY_WEEK',
    notes:
        'Entry of Jesus into Jerusalem and beginning of Holy Week.',
  ),
  _FeastData(
    id: 'EASTER_DAY',
    name: 'Easter Day (Resurrection of the Lord)',
    colour: 'White / Gold',
    seasonId: 'EASTER_SEASON',
    notes:
        'Central feast of the Christian year; celebration of the resurrection.',
  ),
  _FeastData(
    id: 'PENTECOST',
    name: 'Pentecost Sunday',
    colour: 'Red',
    seasonId: 'PENTECOST_DAY',
    notes:
        'Outpouring of the Holy Spirit; birth of the Church.',
  ),
  _FeastData(
    id: 'TRINITY_SUNDAY',
    name: 'Trinity Sunday',
    colour: 'White',
    seasonId: 'ORDINARY_TIME',
    notes:
        'First Sunday after Pentecost; celebration of the Holy Trinity.',
  ),
];

class ChristianCalendarScreen extends StatefulWidget {
  const ChristianCalendarScreen({super.key});

  @override
  State<ChristianCalendarScreen> createState() => _ChristianCalendarScreenState();
}

class _ChristianCalendarScreenState extends State<ChristianCalendarScreen> {
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final easter = _computeEasterSunday(_year);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final ascension = easter.add(const Duration(days: 39));
    final pentecost = easter.add(const Duration(days: 49));
    final currentSeasonId = _inferSeason(today, easter, ashWednesday, pentecost);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Text('Christian Calendar'),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _year,
                  items: [for (int y = DateTime.now().year - 10; y <= DateTime.now().year + 10; y++)
                    DropdownMenuItem(value: y, child: Text('$y'))
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _year = val);
                  },
                ),
              ),
            ),
            if (_year != DateTime.now().year) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Reset to current year',
                onPressed: () => setState(() => _year = DateTime.now().year),
              ),
            ],
          ]),
          bottom: const TabBar(tabs: [
            Tab(text: 'Seasons'),
            Tab(text: 'Feasts'),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildSeasonsView(context, currentSeasonId),
            _buildFeastsView(context, easter, ashWednesday, ascension, pentecost),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonsView(BuildContext context, String currentSeasonId) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChristianCalendarBanner(),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _seasons.length,
              itemBuilder: (_, i) {
                final s = _seasons[i];
                final isCurrent = s.id == currentSeasonId;
                return Card(
                  elevation: isCurrent ? 4 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      border: Border.all(color: isCurrent ? Colors.indigo : Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.cycle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Row(children: [
                              _colourDot(s.primaryColour),
                              if (s.altColour != null) const SizedBox(width: 6),
                              if (s.altColour != null) _colourDot(s.altColour!),
                            ])
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _seasonIconForColour(s.primaryColour),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            if (isCurrent)
                              const Icon(Icons.star, color: Colors.indigo, size: 18),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, children: [
                          _pill(s.primaryColour),
                          if (s.altColour != null) _pill('or ${s.altColour}'),
                        ]),
                        const SizedBox(height: 8),
                        Expanded(child: Text(s.summary, style: const TextStyle(color: Colors.black87))),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.schedule, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(child: Text(s.startHint, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeastsView(BuildContext context, DateTime easter, DateTime ashWednesday, DateTime ascension, DateTime pentecost) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        itemCount: _feasts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final f = _feasts[i];
          final seasonName = _seasons.firstWhere((s) => s.id == f.seasonId).name;
          final dateText = _feastDateText(f.id, easter, ashWednesday, ascension, pentecost);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _easterTimeline(easter, ashWednesday, ascension, pentecost),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(f.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      _colourDot(f.colour),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(seasonName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (dateText != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.event, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(dateText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ],
                  const SizedBox(height: 8),
                  Text(f.notes),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _easterTimeline(DateTime easter, DateTime ashWednesday, DateTime ascension, DateTime pentecost) {
    // Compact horizontal timeline markers for key dates
    final dates = [ashWednesday, easter, ascension, pentecost];
    final labels = ['Ash Wed', 'Easter', 'Ascension', 'Pentecost'];
    final start = ashWednesday;
    final end = pentecost;
    double pos(DateTime d) => (d.difference(start).inDays / end.difference(start).inDays).clamp(0, 1).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      height: 44,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(height: 2, color: Colors.black12),
            ),
          ),
          for (int i = 0; i < dates.length; i++)
            Positioned(
              left: 8 + pos(dates[i]) * (MediaQuery.of(context).size.width - 64),
              top: 6,
              child: Column(
                children: [
                  Container(width: 2, height: 12, color: Colors.indigo),
                  const SizedBox(height: 4),
                  Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _colourDot(String label) {
    final color = _mapColour(label);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _mapColour(String label) {
    final l = label.toLowerCase();
    if (l.contains('violet') || l.contains('purple')) return const Color(0xFF6A1B9A);
    if (l.contains('blue')) return const Color(0xFF3949AB);
    if (l.contains('green')) return const Color(0xFF2E7D32);
    if (l.contains('red')) return const Color(0xFFD32F2F);
    if (l.contains('white')) return const Color(0xFFFFFDE7);
    if (l.contains('gold')) return const Color(0xFFFFD54F);
    if (l.contains('black')) return const Color(0xFF424242);
    return Colors.grey.shade400;
  }

  // --- Enhancements: movable feasts & season inference ---
  DateTime _computeEasterSunday(int year) {
    // Anonymous Gregorian algorithm
    final a = year % 19;
    final b = (year ~/ 100);
    final c = year % 100;
    final d = (b ~/ 4);
    final e = b % 4;
    final f = ((b + 8) ~/ 25);
    final g = ((b - f + 1) ~/ 3);
    final h = (19 * a + b - d - g + 15) % 30;
    final i = (c ~/ 4);
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = ((a + 11 * h + 22 * l) ~/ 451);
    final month = ((h + l - 7 * m + 114) ~/ 31);
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  String _inferSeason(DateTime now, DateTime easter, DateTime ashWednesday, DateTime pentecost) {
    final christmasStart = DateTime(now.year, 12, 24);
    final epiphanyStart = DateTime(now.year, 1, 6);
    final adventStart = _fourthSundayBefore(DateTime(now.year, 12, 25));

    if (now.isAfter(adventStart) && now.isBefore(christmasStart)) return 'ADVENT';
    if (now.isAfter(christmasStart) && now.isBefore(epiphanyStart.add(const Duration(days: 12)))) return 'CHRISTMAS';
    if (now.isAfter(epiphanyStart) && now.isBefore(ashWednesday)) return 'EPIPHANY_SEASON';
    if (now.isAfter(ashWednesday) && now.isBefore(easter)) return 'LENT';
    final holyWeekStart = easter.subtract(const Duration(days: 7));
    if (now.isAfter(holyWeekStart) && now.isBefore(easter)) return 'HOLY_WEEK';
    final easterSeasonEnd = pentecost;
    if (now.isAfter(easter) && now.isBefore(easterSeasonEnd)) return 'EASTER_SEASON';
    if (now.isAfter(pentecost)) return 'ORDINARY_TIME';
    return 'ORDINARY_TIME';
  }

  DateTime _fourthSundayBefore(DateTime christmas) {
    // Find the fourth Sunday before Christmas
    var date = christmas;
    int sundaysFound = 0;
    while (sundaysFound < 4) {
      date = date.subtract(const Duration(days: 1));
      if (date.weekday == DateTime.sunday) sundaysFound++;
    }
    return date;
  }

  String? _feastDateText(String feastId, DateTime easter, DateTime ashWednesday, DateTime ascension, DateTime pentecost) {
    switch (feastId) {
      case 'ASH_WEDNESDAY':
        return 'Ash Wednesday: ${_fmt(ashWednesday)}';
      case 'EASTER_DAY':
        return 'Easter Sunday: ${_fmt(easter)}';
      case 'ASCENSION':
        return 'Ascension: ${_fmt(ascension)}';
      case 'PENTECOST':
        return 'Pentecost: ${_fmt(pentecost)}';
      default:
        return null;
    }
  }

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget _seasonIconForColour(String colour) {
    final l = colour.toLowerCase();
    IconData icon;
    if (l.contains('violet')) {
      icon = Icons.nightlight_round;
    } else if (l.contains('blue')) {
      icon = Icons.star_border;
    } else if (l.contains('green')) {
      icon = Icons.eco;
    } else if (l.contains('red')) {
      icon = Icons.local_fire_department;
    } else if (l.contains('white') || l.contains('gold')) {
      icon = Icons.wb_sunny_outlined;
    } else {
      icon = Icons.circle_outlined;
    }
    return Icon(icon, size: 18, color: Colors.grey.shade700);
  }
}
