import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/services/task_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap; // Callback to handle task interactions
  final VoidCallback onDelete; // Callback to handle task deletion
  final VoidCallback onCreateSubTask; // Callback to handle sub-task creation

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onCreateSubTask,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool isChecked = false; // Track whether the task is completed

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isCompleted; // Initialize based on task state
  }

  Future<void> toggleCheck() async {
    setState(() {
      isChecked = !isChecked; // Toggle the local state
    });

    try {
      final taskService = TaskService();
      await taskService.updateTaskCompletion(widget.task.id!, isChecked); // Update on the server
      widget.task.isCompleted = isChecked; // Update the task's state locally
      widget.onTap(); // Notify the parent widget of changes
    } catch (e) {
      // Rollback the state if the server update fails
      setState(() {
        isChecked = !isChecked; // Revert local state
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap, // Trigger the onTap callback on tap
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isChecked ? Colors.green[100] : Colors.red[100], // Change color based on isChecked
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task.description ?? "No description available",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Actions: Check/Uncheck, Add Sub-Task, Delete Task
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isChecked ? Colors.green : Colors.red,
                    ),
                    onPressed: toggleCheck, // Handle toggle on press
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: widget.onCreateSubTask, // Handle sub-task creation
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete, // Handle task deletion
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
