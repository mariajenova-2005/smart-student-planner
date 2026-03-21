class TaskModel {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  bool isCompleted;
  String category;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    this.category = 'other',
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> j) => TaskModel(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        dueDate: DateTime.parse(j['due_date']),
        priority: j['priority'] ?? 'medium',
        isCompleted: j['is_completed'] ?? false,
        category: j['category'] ?? 'other',
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority,
        'isCompleted': isCompleted,
        'category': category,
      };
}
