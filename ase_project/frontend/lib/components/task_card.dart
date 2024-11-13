// lib/components/task_card.dart
import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description ?? 'No description'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Urgency: ${task.urgency}'),
            Text('Importance: ${task.importance}'),
          ],
        ),
        onTap: () {
          // Handle task tap (e.g., navigate to details)
        },
      ),
    );
  }
}
