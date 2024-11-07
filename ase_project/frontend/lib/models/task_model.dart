
// task_model.dart
class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
