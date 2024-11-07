// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Chip(
                label: Text(task.priority),
                backgroundColor: task.priority == 'High' 
                  ? Colors.red[200] 
                  : task.priority == 'Medium' 
                    ? Colors.orange[200] 
                    : Colors.green[200],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
