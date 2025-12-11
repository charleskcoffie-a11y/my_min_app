/// Idea model for ministry ideas journal
class Idea {
  final String? id;
  final DateTime ideaDate;
  final String? place;
  final String note;
  final DateTime? createdAt;

  Idea({
    this.id,
    required this.ideaDate,
    this.place,
    required this.note,
    this.createdAt,
  });

  factory Idea.fromMap(Map<String, dynamic> map) {
    return Idea(
      id: map['id'] as String?,
      ideaDate: DateTime.parse(map['idea_date'] as String),
      place: map['place'] as String?,
      note: map['note'] as String? ?? '',
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idea_date': ideaDate.toIso8601String(),
      'place': place,
      'note': note,
    };
  }

  Idea copyWith({
    String? id,
    DateTime? ideaDate,
    String? place,
    String? note,
    DateTime? createdAt,
  }) {
    return Idea(
      id: id ?? this.id,
      ideaDate: ideaDate ?? this.ideaDate,
      place: place ?? this.place,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
