/// Sermon/Talk note model
class SermonNote {
  final String? id;
  final String preacher;
  final DateTime noteDate;
  final String location;
  final String sermonTitle;
  final String mainScripture;
  final String openingRemarks;
  final String passageContext;
  final String keyThemes;
  final String keyDoctrines;
  final String theologicalStrengths;
  final String theologicalQuestions;
  final String toneAtmosphere;
  final String useOfScripture;
  final String useOfStories;
  final String audienceEngagement;
  final String flowTransitions;
  final String memorablePhrases;
  final String ministerLessons;
  final String personalChallenge;
  final String applicationToPreaching;
  final String pastoralInsights;
  final String callsToAction;
  final String spiritualChallenges;
  final String practicalApplications;
  final String prayerPoints;
  final String closingScripture;
  final String centralMessageSummary;
  final String finalMemorableLine;
  final String followupScriptures;
  final String followupTopics;
  final String followupPeople;
  final String followupMinistryIdeas;
  final DateTime? createdAt;

  // Points stored separately
  List<SermonPoint> points;

  SermonNote({
    this.id,
    required this.preacher,
    required this.noteDate,
    required this.location,
    required this.sermonTitle,
    required this.mainScripture,
    required this.openingRemarks,
    required this.passageContext,
    required this.keyThemes,
    required this.keyDoctrines,
    required this.theologicalStrengths,
    required this.theologicalQuestions,
    required this.toneAtmosphere,
    required this.useOfScripture,
    required this.useOfStories,
    required this.audienceEngagement,
    required this.flowTransitions,
    required this.memorablePhrases,
    required this.ministerLessons,
    required this.personalChallenge,
    required this.applicationToPreaching,
    required this.pastoralInsights,
    required this.callsToAction,
    required this.spiritualChallenges,
    required this.practicalApplications,
    required this.prayerPoints,
    required this.closingScripture,
    required this.centralMessageSummary,
    required this.finalMemorableLine,
    required this.followupScriptures,
    required this.followupTopics,
    required this.followupPeople,
    required this.followupMinistryIdeas,
    this.createdAt,
    this.points = const [],
  });

  factory SermonNote.fromMap(Map<String, dynamic> map) {
    return SermonNote(
      id: map['id'],
      preacher: map['preacher'] ?? '',
      noteDate: DateTime.parse(map['note_date']),
      location: map['location'] ?? '',
      sermonTitle: map['sermon_title'] ?? '',
      mainScripture: map['main_scripture'] ?? '',
      openingRemarks: map['opening_remarks'] ?? '',
      passageContext: map['passage_context'] ?? '',
      keyThemes: map['key_themes'] ?? '',
      keyDoctrines: map['key_doctrines'] ?? '',
      theologicalStrengths: map['theological_strengths'] ?? '',
      theologicalQuestions: map['theological_questions'] ?? '',
      toneAtmosphere: map['tone_atmosphere'] ?? '',
      useOfScripture: map['use_of_scripture'] ?? '',
      useOfStories: map['use_of_stories'] ?? '',
      audienceEngagement: map['audience_engagement'] ?? '',
      flowTransitions: map['flow_transitions'] ?? '',
      memorablePhrases: map['memorable_phrases'] ?? '',
      ministerLessons: map['minister_lessons'] ?? '',
      personalChallenge: map['personal_challenge'] ?? '',
      applicationToPreaching: map['application_to_preaching'] ?? '',
      pastoralInsights: map['pastoral_insights'] ?? '',
      callsToAction: map['calls_to_action'] ?? '',
      spiritualChallenges: map['spiritual_challenges'] ?? '',
      practicalApplications: map['practical_applications'] ?? '',
      prayerPoints: map['prayer_points'] ?? '',
      closingScripture: map['closing_scripture'] ?? '',
      centralMessageSummary: map['central_message_summary'] ?? '',
      finalMemorableLine: map['final_memorable_line'] ?? '',
      followupScriptures: map['followup_scriptures'] ?? '',
      followupTopics: map['followup_topics'] ?? '',
      followupPeople: map['followup_people'] ?? '',
      followupMinistryIdeas: map['followup_ministry_ideas'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'preacher': preacher,
      'note_date': noteDate.toIso8601String().split('T').first,
      'location': location,
      'sermon_title': sermonTitle,
      'main_scripture': mainScripture,
      'opening_remarks': openingRemarks,
      'passage_context': passageContext,
      'key_themes': keyThemes,
      'key_doctrines': keyDoctrines,
      'theological_strengths': theologicalStrengths,
      'theological_questions': theologicalQuestions,
      'tone_atmosphere': toneAtmosphere,
      'use_of_scripture': useOfScripture,
      'use_of_stories': useOfStories,
      'audience_engagement': audienceEngagement,
      'flow_transitions': flowTransitions,
      'memorable_phrases': memorablePhrases,
      'minister_lessons': ministerLessons,
      'personal_challenge': personalChallenge,
      'application_to_preaching': applicationToPreaching,
      'pastoral_insights': pastoralInsights,
      'calls_to_action': callsToAction,
      'spiritual_challenges': spiritualChallenges,
      'practical_applications': practicalApplications,
      'prayer_points': prayerPoints,
      'closing_scripture': closingScripture,
      'central_message_summary': centralMessageSummary,
      'final_memorable_line': finalMemorableLine,
      'followup_scriptures': followupScriptures,
      'followup_topics': followupTopics,
      'followup_people': followupPeople,
      'followup_ministry_ideas': followupMinistryIdeas,
    };
  }

  SermonNote copyWith({List<SermonPoint>? points}) {
    return SermonNote(
      id: id,
      preacher: preacher,
      noteDate: noteDate,
      location: location,
      sermonTitle: sermonTitle,
      mainScripture: mainScripture,
      openingRemarks: openingRemarks,
      passageContext: passageContext,
      keyThemes: keyThemes,
      keyDoctrines: keyDoctrines,
      theologicalStrengths: theologicalStrengths,
      theologicalQuestions: theologicalQuestions,
      toneAtmosphere: toneAtmosphere,
      useOfScripture: useOfScripture,
      useOfStories: useOfStories,
      audienceEngagement: audienceEngagement,
      flowTransitions: flowTransitions,
      memorablePhrases: memorablePhrases,
      ministerLessons: ministerLessons,
      personalChallenge: personalChallenge,
      applicationToPreaching: applicationToPreaching,
      pastoralInsights: pastoralInsights,
      callsToAction: callsToAction,
      spiritualChallenges: spiritualChallenges,
      practicalApplications: practicalApplications,
      prayerPoints: prayerPoints,
      closingScripture: closingScripture,
      centralMessageSummary: centralMessageSummary,
      finalMemorableLine: finalMemorableLine,
      followupScriptures: followupScriptures,
      followupTopics: followupTopics,
      followupPeople: followupPeople,
      followupMinistryIdeas: followupMinistryIdeas,
      createdAt: createdAt,
      points: points ?? this.points,
    );
  }
}

/// Sermon point (child)
class SermonPoint {
  final String? id;
  final String? noteId;
  final int pointNumber;
  final String mainPoint;
  final String supportingScripture;
  final String keyQuotes;
  final String illustrations;
  final String ministryEmphasis;

  SermonPoint({
    this.id,
    this.noteId,
    required this.pointNumber,
    required this.mainPoint,
    required this.supportingScripture,
    required this.keyQuotes,
    required this.illustrations,
    required this.ministryEmphasis,
  });

  factory SermonPoint.fromMap(Map<String, dynamic> map) {
    return SermonPoint(
      id: map['id'],
      noteId: map['note_id'],
      pointNumber: map['point_number'] ?? 1,
      mainPoint: map['main_point'] ?? '',
      supportingScripture: map['supporting_scripture'] ?? '',
      keyQuotes: map['key_quotes'] ?? '',
      illustrations: map['illustrations'] ?? '',
      ministryEmphasis: map['ministry_emphasis'] ?? '',
    );
  }

  Map<String, dynamic> toMap(String noteId) {
    return {
      'note_id': noteId,
      'point_number': pointNumber,
      'main_point': mainPoint,
      'supporting_scripture': supportingScripture,
      'key_quotes': keyQuotes,
      'illustrations': illustrations,
      'ministry_emphasis': ministryEmphasis,
    };
  }
}
