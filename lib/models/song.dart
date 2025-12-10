/// Song model for Methodist hymns and canticles
class Song {
  final int id;
  final String collection;
  final String code;
  final int number;
  final String title;
  final String lyrics;
  final String? author;
  final String? copyright;
  final List<String>? tags;
  bool isFavorite;

  Song({
    required this.id,
    required this.collection,
    required this.code,
    required this.number,
    required this.title,
    required this.lyrics,
    this.author,
    this.copyright,
    this.tags,
    this.isFavorite = false,
  });

  /// Create Song from Supabase map/JSON
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as int,
      collection: map['collection'] as String? ?? '',
      code: map['code'] as String? ?? '',
      number: map['number'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      lyrics: map['lyrics'] as String? ?? '',
      author: map['author'] as String?,
      copyright: map['copyright'] as String?,
      tags: map['tags'] is List ? List<String>.from(map['tags'] as List) : null,
      isFavorite: map['is_favorite'] as bool? ?? false,
    );
  }

  /// Convert Song to map for Supabase update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection': collection,
      'code': code,
      'number': number,
      'title': title,
      'lyrics': lyrics,
      'author': author,
      'copyright': copyright,
      'tags': tags,
      'is_favorite': isFavorite,
    };
  }

  /// Create a copy with modified fields
  Song copyWith({
    int? id,
    String? collection,
    String? code,
    int? number,
    String? title,
    String? lyrics,
    String? author,
    String? copyright,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      code: code ?? this.code,
      number: number ?? this.number,
      title: title ?? this.title,
      lyrics: lyrics ?? this.lyrics,
      author: author ?? this.author,
      copyright: copyright ?? this.copyright,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
