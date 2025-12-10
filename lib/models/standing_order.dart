class StandingOrder {
  final String id;
  final String code;
  final String title;
  final String content;
  final bool isFavorite;
  final List<String> tags;

  StandingOrder({
    required this.id,
    required this.code,
    required this.title,
    required this.content,
    required this.isFavorite,
    required this.tags,
  });

  factory StandingOrder.fromMap(Map<String, dynamic> map) {
    return StandingOrder(
      id: map['id'] as String,
      code: map['code'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isFavorite: map['is_favorite'] as bool? ?? false,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'title': title,
        'content': content,
        'is_favorite': isFavorite,
        'tags': tags,
      };

  StandingOrder copyWith({
    String? id,
    String? code,
    String? title,
    String? content,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return StandingOrder(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}
