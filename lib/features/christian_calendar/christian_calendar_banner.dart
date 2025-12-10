import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'season.dart';
import 'season_details_screen.dart';

class ChristianCalendarBanner extends StatelessWidget {
  const ChristianCalendarBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final season = getSeasonForDate(today);
    final dayText = DateFormat.yMMMMEEEEd().format(today);
    final seasonRange = '${DateFormat.yMMMd().format(season.startDate)} — ${DateFormat.yMMMd().format(season.endDate)}';

    final textColor = season.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Semantics(
      label: 'Liturgical season banner. ${season.name} season. Tap for details.',
      child: InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SeasonDetailsScreen(date: today, season: season),
        ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: season.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayText, style: TextStyle(color: textColor.withAlpha((0.9 * 255).toInt()), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(season.name, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(seasonRange, style: TextStyle(color: textColor.withAlpha((0.9 * 255).toInt()), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(season.explanation, style: TextStyle(color: textColor.withAlpha((0.95 * 255).toInt())), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Colour', style: TextStyle(color: textColor.withAlpha((0.85 * 255).toInt()), fontSize: 12)),
                const SizedBox(height: 6),
                Container(width: 36, height: 36, decoration: BoxDecoration(color: season.color, border: Border.all(color: textColor.withAlpha((0.4 * 255).toInt())), borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                if (season.vestmentSuggestion != null) Text('Vestments', style: TextStyle(color: textColor.withAlpha((0.85 * 255).toInt()), fontSize: 12)),
                if (season.vestmentSuggestion != null)
                  SizedBox(width: 120, child: Text(season.vestmentSuggestion!, style: TextStyle(color: textColor.withAlpha((0.98 * 255).toInt())), textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 6),
                Text('Lectionary ${season.lectionaryYear}', style: TextStyle(color: textColor.withAlpha((0.95 * 255).toInt()), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
