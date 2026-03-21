class NoteModel {
  final String id;
  String subject;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.subject,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> j) => NoteModel(
        id: j['id'] ?? '',
        subject: j['subject'] ?? '',
        title: j['title'] ?? '',
        content: j['content'] ?? '',
        createdAt: DateTime.parse(j['created_at']),
        updatedAt: DateTime.parse(j['updated_at']),
      );
}
