import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  TaskDetailPage({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title), // Use a default value if title is null
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(task.description ?? "No description available"), // Handle null description
            SizedBox(height: 16),
            Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(task.urgency), // Handle null priority
            SizedBox(height: 16),
            Text('Due Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(task.dueDate?.toString() ?? "No due date"), // Handle null dueDate
            // Add more fields as needed to display additional task details
          ],
        ),
      ),
    );
  }
}
