import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';


class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap; 
  final VoidCallback onDelete; 
  final VoidCallback onCreateSubTask; 


  const TaskCard({
    super.key, 
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onCreateSubTask,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [         
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                  Column(
                    children: [
                      //Sub-Task add 
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.blue),
                        onPressed: onCreateSubTask, 
                      ),
                      // Task Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete, 
                      ),
                    ],
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
