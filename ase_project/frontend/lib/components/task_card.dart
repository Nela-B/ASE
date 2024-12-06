import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/models/subtask_model.dart';
import '../services/task_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap; // Callback to show task details
  final VoidCallback onDelete; // Callback to delete the task
  final VoidCallback onCreateSubTask; // Callback to create a subtask
  final ValueChanged<bool> onCompletionToggle; // Callback to toggle task completion

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onCreateSubTask,
    required this.onCompletionToggle,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TaskService taskService = TaskService(); // Instance of TaskService
  List<SubTask> subtasks = [];

  @override
  void initState() {
    super.initState();
    _fetchSubtasks(); // Load subtasks on initialization
  }

  Future<void> _fetchSubtasks() async {
    final taskId = widget.task.id;
    final url = 'http://localhost:3000/api/tasks/$taskId/subtask/list';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<SubTask> fetchedSubtasks = (data['subtasks'] as List)
            .map((subtaskData) => SubTask.fromJson(subtaskData))
            .toList();

        setState(() {
          subtasks = fetchedSubtasks;
        });
      } else {
        throw Exception('Failed to load subtasks');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Calculate the card color based on the state of its subtasks
  Color _getCardColor() {
    if (subtasks.isEmpty) {
      return widget.task.isCompleted ? Colors.green[100]! : Colors.red[100]!;
    }

    final allCompleted = subtasks.every((subtask) => subtask.isCompleted);
    final anyCompleted = subtasks.any((subtask) => subtask.isCompleted);

    if (allCompleted) {
      return Colors.green[100]!;
    } else if (anyCompleted) {
      return Colors.orange[100]!;
    } else {
      return Colors.red[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Navigate to task details
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: _getCardColor(), // Dynamic color based on subtask status
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: Title, due date, and status button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Due date
                  if (widget.task.dueDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  // Status button
                  IconButton(
                    icon: Icon(
                      widget.task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: widget.task.isCompleted ? Colors.green : Colors.red,
                    ),
                    onPressed: () =>
                        widget.onCompletionToggle(!widget.task.isCompleted), // Toggle task status
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Middle section: Description
              if (widget.task.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.task.description!,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),

              // Subtasks
              if (subtasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Subtasks:",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...subtasks.map(
                      (subTask) => Row(
                        children: [
                          Checkbox(
                            value: subTask.isCompleted,
                            onChanged: (value) async {
                              if (value != null) {
                                try {
                                  await taskService.updateSubTaskCompletion(subTask.id, value);
                                  setState(() {
                                    subTask.isCompleted = value;
                                  });
                                } catch (e) {
                                  print("Error updating subtask: $e");
                                }
                              }
                            },
                          ),
                          Expanded(
                            child: Text(
                              subTask.title,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: subTask.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Bottom section: Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: widget.onCreateSubTask, // Add a subtask
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete, // Delete the task
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
