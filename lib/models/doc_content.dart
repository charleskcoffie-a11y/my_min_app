class DocContent {
  final String id;
  final String text;
  final int? page;

  DocContent({required this.id, required this.text, this.page});

  factory DocContent.fromMap(Map<String, dynamic> map) {
    return DocContent(
      id: map['id'] as String,
      text: map['text'] as String,
      page: map['page'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        if (page != null) 'page': page,
      };
}
