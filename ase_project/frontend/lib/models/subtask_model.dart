class SubTask {
    String id;
    String title;
    bool isCompleted;

    SubTask({required this.id, required this.title, this.isCompleted = false});

    factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['_id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}