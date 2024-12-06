// subtask_model.dart

class SubTask {
  final String id;
  final String title;
  final String description;
  final String deadlineType;
  final DateTime? dueDate;
  bool isCompleted;
  final String urgency;
  final String importance;
  final List<String> links; 
  final List<String> filePaths; 
  final bool notify;
  final String frequency;
  final int interval;
  final List<int> byDay; 
  final int byMonthDay;
  final String recurrenceEndType;
  final DateTime? recurrenceEndDate;
  final int maxOccurrences;
  final int points;
  final List<String> errands;

  SubTask({
    required this.id,
    required this.title,
    required this.description,
    required this.deadlineType,
    this.dueDate,
    required this.isCompleted,
    required this.urgency,
    required this.importance,
    required this.links,
    required this.filePaths,
    required this.notify,
    required this.frequency,
    required this.interval,
    required this.byDay,
    required this.byMonthDay,
    required this.recurrenceEndType,
    this.recurrenceEndDate,
    required this.maxOccurrences,
    required this.points,
    required this.errands,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    try {
      return SubTask(
        id: json['_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        deadlineType: json['deadlineType'] as String,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        isCompleted: json['isCompleted'] as bool,
        urgency: json['urgency'] as String,
        importance: json['importance'] as String,
        links: List<String>.from(json['links'] ?? []), 
        filePaths: List<String>.from(json['filePaths'] ?? []),
        notify: json['notify'] as bool,
        frequency: json['frequency'] as String,
        interval: json['interval'] as int,
        byDay: List<int>.from(json['byDay'] ?? []), 
        byMonthDay: json['byMonthDay'] as int,
        recurrenceEndType: json['recurrenceEndType'] as String,
        recurrenceEndDate: json['recurrenceEndDate'] != null ? DateTime.parse(json['recurrenceEndDate']) : null,
        maxOccurrences: json['maxOccurrences'] as int,
        points: json['points'] as int,
        errands: List<String>.from(json['errands'] ?? []), 
      );
    } catch (e) {
      print("Error parsing SubTask from JSON: $e");
      rethrow;
    }
  }

 Map<String, dynamic> toJson() {
  return {
    '_id': id,
    'title': title,
    'description': description,
    'deadlineType': deadlineType,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'urgency': urgency,
    'importance': importance,
    'links': links,
    'filePaths': filePaths,
    'notify': notify,
    'frequency': frequency,
    'interval': interval,
    'byDay': byDay,
    'byMonthDay': byMonthDay,
    'recurrenceEndType': recurrenceEndType,
    'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
    'maxOccurrences': maxOccurrences,
    'points': points,
    'errands': errands,
  };
}


}
