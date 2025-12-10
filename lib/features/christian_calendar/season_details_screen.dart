import 'package:flutter/material.dart';
import 'season.dart';
import 'package:intl/intl.dart';

class SeasonDetailsScreen extends StatelessWidget {
  final DateTime date;
  final Season season;

  const SeasonDetailsScreen({super.key, required this.date, required this.season});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMMEEEEd().format(date);
    // compute some key dates for the current liturgical year
    DateTime firstSundayOfAdvent(int year) {
      final dec3 = DateTime(year, 12, 3);
      final dow = dec3.weekday; // 1=Mon ... 7=Sun
      final daysBack = dow % 7;
      return dec3.subtract(Duration(days: daysBack));
    }

    final adventThisYear = firstSundayOfAdvent(date.year);
    final liturgicalYearStart = date.isAtSameMomentAs(adventThisYear) || date.isAfter(adventThisYear) ? date.year : date.year - 1;
    final easter = getEasterForLiturgicalYear(liturgicalYearStart);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final ascension = easter.add(const Duration(days: 39));
    final pentecost = easter.add(const Duration(days: 49));
    final allSaints = DateTime(date.year, 11, 1);
    final textColor = season.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(title: Text('${season.name} Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateText, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: season.color, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(season.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                Text(season.explanation, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
                const SizedBox(height: 8),
                Text('Season dates: ${DateFormat.yMMMd().format(season.startDate)} — ${DateFormat.yMMMd().format(season.endDate)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor)),
                const SizedBox(height: 8),
                Text('Lectionary Year: ${season.lectionaryYear}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 8),
                if (season.vestmentSuggestion != null) ...[
                  Text('Vestment suggestion:', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Text(season.vestmentSuggestion!, style: TextStyle(color: textColor)),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            const Text('Key dates this liturgical year', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Easter: ${DateFormat.yMMMd().format(easter)}'),
            Text('Ash Wednesday: ${DateFormat.yMMMd().format(ashWednesday)}'),
            Text('Ascension: ${DateFormat.yMMMd().format(ascension)}'),
            Text('Pentecost: ${DateFormat.yMMMd().format(pentecost)}'),
            Text('All Saints: ${DateFormat.yMMMd().format(allSaints)}'),
            const SizedBox(height: 12),
            const Text('More information', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This view gives a short overview of the current liturgical season. For fuller resources consult church liturgy guides or diocesan materials.'),
          ],
        ),
      ),
    );
  }
}
