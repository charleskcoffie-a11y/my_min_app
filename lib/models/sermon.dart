import 'package:uuid/uuid.dart';

class Sermon {
  final String id;
  String title;
  String theme;
  String mainText;
  List<String> supportingScriptures;
  List<String> outline;
  List<String> applications;
  List<String> prayerPoints;
  String introduction;
  String backgroundContext;
  List<Map<String, String>> mainPoints;
  String gospelConnection;
  String conclusion;
  String closingPrayer;
  String altarCall;
  String proposition;

  Sermon({
    String? id,
    required this.title,
    required this.theme,
    required this.mainText,
    List<String>? supportingScriptures,
    List<String>? outline,
    List<String>? applications,
    List<String>? prayerPoints,
    String? introduction,
    String? backgroundContext,
    List<Map<String, String>>? mainPoints,
    String? gospelConnection,
    String? conclusion,
    String? closingPrayer,
    String? altarCall,
    String? proposition,
  })  : id = id ?? const Uuid().v4(),
        supportingScriptures = supportingScriptures ?? [],
        outline = outline ?? [],
        applications = applications ?? [],
        prayerPoints = prayerPoints ?? [],
        introduction = introduction ?? '',
        backgroundContext = backgroundContext ?? '',
        mainPoints = mainPoints ?? [],
        gospelConnection = gospelConnection ?? '',
        conclusion = conclusion ?? '',
        closingPrayer = closingPrayer ?? '',
        altarCall = altarCall ?? '',
        proposition = proposition ?? '';
        

  Map<String, dynamic> toJson() => {
      // Use snake_case keys to match typical Supabase column naming
      'id': id,
      'title': title,
      'theme': theme,
      'main_text': mainText,
      'supporting_scriptures': supportingScriptures,
      'introduction': introduction,
      'background_context': backgroundContext,
      'main_points': mainPoints,
      'outline': outline,
      'applications': applications,
      'gospel_connection': gospelConnection,
      'conclusion': conclusion,
      'closing_prayer': closingPrayer,
      'altar_call': altarCall,
      'prayer_points': prayerPoints,
      'proposition': proposition,
      };

  factory Sermon.fromJson(Map<String, dynamic> json) {
    // Accept both camelCase and snake_case keys for compatibility
    String getString(Map<String, dynamic> m, String a, String b) {
      return (m[a] ?? m[b] ?? '') as String;
    }

    List<String> getList(Map<String, dynamic> m, String a, String b) {
      final v = m[a] ?? m[b] ?? [];
      return List<String>.from(v);
    }

    List<Map<String, String>> getMainPoints(Map<String, dynamic> m, String a, String b) {
      final v = m[a] ?? m[b] ?? [];
      final list = List<Map<String, dynamic>>.from(v);
      return list.map((e) => e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))).toList();
    }

    return Sermon(
      id: json['id'] as String?,
      title: getString(json, 'title', 'title'),
      theme: getString(json, 'theme', 'theme'),
      mainText: getString(json, 'mainText', 'main_text'),
      supportingScriptures: getList(json, 'supportingScriptures', 'supporting_scriptures'),
      introduction: getString(json, 'introduction', 'introduction'),
      backgroundContext: getString(json, 'backgroundContext', 'background_context'),
      mainPoints: getMainPoints(json, 'mainPoints', 'main_points'),
      outline: getList(json, 'outline', 'outline'),
      applications: getList(json, 'applications', 'applications'),
      gospelConnection: getString(json, 'gospelConnection', 'gospel_connection'),
      conclusion: getString(json, 'conclusion', 'conclusion'),
      closingPrayer: getString(json, 'closingPrayer', 'closing_prayer'),
      altarCall: getString(json, 'altarCall', 'altar_call'),
      prayerPoints: getList(json, 'prayerPoints', 'prayer_points'),
      proposition: getString(json, 'proposition', 'proposition'),
    );
  }
}
