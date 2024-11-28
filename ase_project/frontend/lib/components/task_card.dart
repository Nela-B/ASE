import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/services/task_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onCreateSubTask;
  final ValueChanged<bool> onCompletionToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onCreateSubTask,
    required this.onCompletionToggle,
  });

  Future<void> toggleCheck(BuildContext context) async {
    try {
      final taskService = TaskService();
      final newCompletionStatus = !task.isCompleted;
      await taskService.updateTaskCompletion(task.id!, newCompletionStatus);
      onCompletionToggle(newCompletionStatus);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: task.isCompleted ? Colors.green[100] : Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description ?? "No description available",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task.isCompleted ? Colors.green : Colors.red,
                    ),
                    onPressed: () => toggleCheck(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: onCreateSubTask,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
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