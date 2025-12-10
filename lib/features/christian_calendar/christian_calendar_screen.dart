import 'package:flutter/material.dart';
import 'christian_calendar_banner.dart';

class ChristianCalendarScreen extends StatelessWidget {
  const ChristianCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Christian Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChristianCalendarBanner(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tap the banner for full season details.', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 24),
                    const Text('Liturgical Colours & Vestments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _colourLegendItem('Advent', const Color(0xFF4A148C), 'Purple or blue'),
                    _colourLegendItem('Christmas', const Color(0xFFFFF9C4), 'White or gold'),
                    _colourLegendItem('Epiphany', const Color(0xFF2E7D32), 'Green'),
                    _colourLegendItem('Lent', const Color(0xFF6A1B9A), 'Purple'),
                    _colourLegendItem('Holy Week', const Color(0xFFD32F2F), 'Red or black'),
                    _colourLegendItem('Easter', const Color(0xFFFFF176), 'White or gold'),
                    _colourLegendItem('Pentecost', const Color(0xFFD32F2F), 'Red'),
                    _colourLegendItem('Ascension', const Color(0xFFD32F2F), 'White or red'),
                    _colourLegendItem('All Saints', const Color(0xFFFFF9C4), 'White or gold'),
                    _colourLegendItem('Ordinary Time', const Color(0xFF2E7D32), 'Green'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _colourLegendItem(String name, Color color, String vestment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(vestment, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
