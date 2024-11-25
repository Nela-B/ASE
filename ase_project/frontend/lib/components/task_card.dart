import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/services/task_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap; // Callback to handle task interactions

  TaskCard({required this.task, required this.onTap});

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
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.task.description ?? "No description available",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Check/Uncheck Button
              IconButton(
                icon: Icon(
                  isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isChecked ? Colors.green : Colors.red,
                ),
                onPressed: toggleCheck, // Handle toggle on press
              ),
            ],
          ),
        ),
      ),
    );
  }
}
