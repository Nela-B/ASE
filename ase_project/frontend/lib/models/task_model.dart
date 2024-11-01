import 'package:ase_project/models/subtask_model.dart';

class Task {
    String id;
    String title;
    String description;
    DateTime dueDate;
    bool isCompleted;
    List<SubTask> subTasks;

    Task({required this.id, required this.title, this.description = '', required this.dueDate, this.isCompleted = false, this.subTasks = const []});
}