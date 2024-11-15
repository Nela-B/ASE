import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap; // Pass a callback to handle the tap

  TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Trigger the onTap callback on tap
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(task.description ?? "No description available", style: TextStyle(fontSize: 14)),
              // Add any additional task details you want to display
            ],
          ),
        ),
      ),
    );
  }
}
