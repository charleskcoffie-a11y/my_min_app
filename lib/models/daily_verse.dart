/// Model for daily verses stored in Supabase
class DailyVerse {
  final String id;
  final DateTime? date;
  final String reference; // e.g. "Proverbs 18:12"
  final String translation; // e.g. "NLT"
  final String text; // The verse body
  final String? imageUrl; // Background image URL
  final DateTime createdAt;

  DailyVerse({
    required this.id,
    this.date,
    required this.reference,
    required this.translation,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  /// Create from Supabase JSON
  factory DailyVerse.fromMap(Map<String, dynamic> map) {
    return DailyVerse(
      id: map['id'] as String,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      reference: map['reference'] as String,
      translation: map['translation'] as String,
      text: map['text'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to map for Supabase insert/update
  Map<String, dynamic> toMap() {
    return {
      'date': date?.toIso8601String(),
      'reference': reference,
      'translation': translation,
      'text': text,
      'image_url': imageUrl,
    };
  }

  /// Get a truncated version of the text for notifications
  String getTruncatedText({int maxLength = 150}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get the full reference with translation
  String get fullReference => '$reference - $translation';
}
