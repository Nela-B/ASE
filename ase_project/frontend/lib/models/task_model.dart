
// lib/models/task_model.dart
class Task {
  final String? id;
  final String title;
  final String? description;
  final String deadlineType;
  final DateTime? dueDate;
  bool isCompleted;
  final String urgency;
  final String importance;
  final List<String>? links;
  final List<String>? filePaths;
  final bool notify;
  final String frequency;
  final int? interval;
  final List<String>? byDay;
  final int? byMonthDay;
  final String recurrenceEndType;
  final DateTime? recurrenceEndDate;
  final int? maxOccurrences;
  final int points;
  DateTime? completionDate;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.deadlineType,
    this.dueDate,
    this.isCompleted = false,
    required this.urgency,
    required this.importance,
    this.links,
    this.filePaths,
    this.notify = false,
    required this.frequency,
    this.interval,
    this.byDay,
    this.byMonthDay,
    required this.recurrenceEndType,
    this.recurrenceEndDate,
    this.maxOccurrences,
    this.points = 0,
    this.completionDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      deadlineType: json['deadlineType'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      urgency: json['urgency'],
      importance: json['importance'],
      links: json['links'] != null ? List<String>.from(json['links']) : null,
      filePaths: json['filePaths'] != null ? List<String>.from(json['filePaths']) : null,
      notify: json['notify'] ?? false,
      frequency: json['frequency'],
      interval: json['interval'],
      byDay: json['byDay'] != null ? List<String>.from(json['byDay']) : null,
      byMonthDay: json['byMonthDay'],
      recurrenceEndType: json['recurrenceEndType'],
      recurrenceEndDate: json['recurrenceEndDate'] != null ? DateTime.parse(json['recurrenceEndDate']) : null,
      maxOccurrences: json['maxOccurrences'],
      points: json['points'] ?? 0,
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
    );
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
      'completionDate': completionDate?.toIso8601String()
    };
  }
  
}
