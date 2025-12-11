import '../core/gemini_service.dart';
import '../models/daily_verse.dart';

/// Service for generating AI-powered devotional content using Gemini
class DevotionalAIService {
  final GeminiService _gemini;

  DevotionalAIService(this._gemini);

  /// Generate a morning devotion based on a verse
  /// Returns a 2-3 sentence reflection for Methodist ministers in Ghana
  Future<String> generateDevotion(DailyVerse verse) async {
    final prompt = '''
Write a brief 2-3 sentence morning devotion based on this Bible verse for a Methodist minister in Ghana:

${verse.fullReference}
"${verse.text}"

The devotion should:
- Be warm, encouraging, and pastoral
- Connect to daily ministry life
- Be suitable for a busy morning
- End with a practical application or encouragement

Keep it concise and uplifting.
''';

    try {
      final response = await _gemini.generateText(prompt);
      return response.trim();
    } catch (e) {
      // Fallback devotion
      return 'May this verse guide your ministry today. Let its truth shape your words and actions as you serve God\'s people.';
    }
  }

  /// Generate a prayer based on the verse
  Future<String> generatePrayer(DailyVerse verse) async {
    final prompt = '''
Write a short prayer (2-3 sentences) based on this Bible verse for a Methodist minister:

${verse.fullReference}
"${verse.text}"

The prayer should:
- Be personal and heartfelt
- Reference themes from the verse
- Be suitable for morning meditation
- End with "Amen"

Keep it simple and sincere.
''';

    try {
      final response = await _gemini.generateText(prompt);
      return response.trim();
    } catch (e) {
      return 'Heavenly Father, thank you for your Word today. Help me to live out this truth in my ministry and life. Amen.';
    }
  }

  /// Generate action points for applying the verse
  Future<String> generateActionPoints(DailyVerse verse) async {
    final prompt = '''
Based on this Bible verse, suggest 2-3 practical action points for a Methodist minister in Ghana:

${verse.fullReference}
"${verse.text}"

Format as a simple bulleted list. Keep each point brief and actionable.
Focus on pastoral ministry and daily life.
''';

    try {
      final response = await _gemini.generateText(prompt);
      return response.trim();
    } catch (e) {
      return '• Reflect on this verse throughout the day\n• Share its message with someone who needs encouragement\n• Let it guide your decisions today';
    }
  }

  /// Generate a short notification message
  /// Perfect for push notifications - 1-2 sentences max
  Future<String> generateNotificationMessage(DailyVerse verse) async {
    final prompt = '''
Create a very short (1-2 sentence) inspiring message for a morning notification based on this verse:

${verse.fullReference}
"${verse.text}"

The message should:
- Be encouraging and uplifting
- Capture the essence of the verse
- Be suitable for a push notification (very brief)
- Not include the verse reference (it's already in the title)

Maximum 100 characters.
''';

    try {
      final response = await _gemini.generateText(prompt);
      // Ensure it's short enough for notifications
      final message = response.trim();
      return message.length > 150 
          ? message.substring(0, 147) + '...'
          : message;
    } catch (e) {
      // Fallback to truncated verse
      return verse.getTruncatedText(maxLength: 100);
    }
  }

  /// Generate a complete devotional package
  /// Returns all content needed for the devotion screen
  Future<DevotionalContent> generateComplete(DailyVerse verse) async {
    try {
      // Generate all content in parallel for speed
      final results = await Future.wait([
        generateDevotion(verse),
        generatePrayer(verse),
        generateActionPoints(verse),
      ]);

      return DevotionalContent(
        devotion: results[0],
        prayer: results[1],
        actionPoints: results[2],
      );
    } catch (e) {
      // Return fallback content
      return DevotionalContent(
        devotion: 'Reflect on this verse today and let it guide your ministry.',
        prayer: 'Lord, help me live out your Word today. Amen.',
        actionPoints: '• Meditate on this verse\n• Share it with others\n• Apply it in your ministry',
      );
    }
  }
}

/// Container for devotional content
class DevotionalContent {
  final String devotion;
  final String prayer;
  final String actionPoints;

  DevotionalContent({
    required this.devotion,
    required this.prayer,
    required this.actionPoints,
  });
}
