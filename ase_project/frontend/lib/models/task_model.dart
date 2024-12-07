import 'package:ase_project/models/subtask_model.dart';

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
  late final int? maxOccurrences;
  final int points;
  DateTime? completionDate;
  List<SubTask>? subTasks; // Added SubTask list

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
    this.subTasks, // Initialize SubTask list
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      return Task(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        deadlineType: json['deadlineType'],
        // Handle 'dueDate' conversion
        dueDate: json['dueDate'] != null && json['dueDate'] is String
            ? DateTime.parse(json['dueDate'])
            : null,
        isCompleted: json['isCompleted'] ?? false,
        urgency: json['urgency'],
        importance: json['importance'],
        links: json['links'] != null ? List<String>.from(json['links']) : null,
        filePaths: json['filePaths'] != null
            ? List<String>.from(json['filePaths'])
            : null,
        notify: json['notify'] ?? false,
        frequency: json['frequency'],
        interval: json['interval'],
        byDay: json['byDay'] != null ? List<String>.from(json['byDay']) : null,
        byMonthDay: json['byMonthDay'],
        recurrenceEndType: json['recurrenceEndType'],
        recurrenceEndDate: json['recurrenceEndDate'] != null &&
                json['recurrenceEndDate'] is String
            ? DateTime.parse(json['recurrenceEndDate'])
            : null,
        maxOccurrences: json['maxOccurrences'] ?? 1,
        points: json['points'] ?? 0,
        // Handle 'completionDate' conversion
        completionDate:
            json['completionDate'] != null && json['completionDate'] is String
                ? DateTime.parse(json['completionDate'])
                : null,
        // Handle subTasks if they exist
        subTasks: json['subTasks'] != null
            ? List<SubTask>.from(
                json['subtasks'].map((task) => SubTask.fromJson(task)))
            : [], // Return an empty list if no subTasks
      );
    } catch (e) {
      print("Error parsing Task from JSON: $e");
      rethrow; // Log the error and rethrow
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
      'completionDate': completionDate?.toIso8601String(),
      // Include subtasks
      'subTasks': subTasks?.map((subTask) => subTask.toJson()).toList() ??
          [], // Handle null subTasks by returning an empty list
    };
  }
}
