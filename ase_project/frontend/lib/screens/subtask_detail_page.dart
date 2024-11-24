import 'package:flutter/material.dart';
import 'package:ase_project/models/subtask_model.dart';
import 'package:ase_project/screens/edit_subtask_page.dart';
import 'package:ase_project/services/task_service.dart';

class SubtaskDetailPage extends StatefulWidget {
  final SubTask subtask;

  const SubtaskDetailPage({super.key, required this.subtask});

  @override
  _SubtaskDetailPageState createState() => _SubtaskDetailPageState();
}

class _SubtaskDetailPageState extends State<SubtaskDetailPage> {
  // Method to handle subtask deletion
  Future<void> deleteSubtask() async {
    try {
      // Attempt to delete the subtask using the TaskService
      await TaskService().deleteSubTask(widget.subtask.id);

      // If deletion is successful, show a snackbar and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subtask deleted successfully')),
      );

      // Navigate back to the previous screen
      Navigator.pop(context, true); // Pass `true` to notify deletion was successful
    } catch (e) {
      // If there is an error while deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete subtask')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtask.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSubtaskPage(subtask: widget.subtask),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Show confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Subtask'),
                    content: const Text('Are you sure you want to delete this subtask?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          deleteSubtask(); // Proceed with deletion
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            _buildSectionTitle("Overview"),
            _buildInfoCard(
              icon: Icons.description,
              title: "Description",
              content: widget.subtask.description,
            ),
            _buildInfoCard(
              icon: Icons.access_time,
              title: "Due Date",
              content: widget.subtask.dueDate != null
                  ? widget.subtask.dueDate!.toLocal().toString().split(' ')[0]
                  : "No due date",
            ),
            _buildInfoCard(
              icon: Icons.priority_high,
              title: "Urgency",
              content: widget.subtask.urgency,
            ),
            _buildInfoCard(
              icon: Icons.verified,
              title: "Importance",
              content: widget.subtask.importance,
            ),
            const SizedBox(height: 16),

            // Recurrence Section
            _buildSectionTitle("Recurrence Details"),
            _buildInfoCard(
              icon: Icons.repeat,
              title: "Frequency",
              content: widget.subtask.frequency,
            ),
            _buildInfoCard(
              icon: Icons.date_range,
              title: "Recurrence End",
              content: widget.subtask.recurrenceEndDate != null
                  ? widget.subtask.recurrenceEndDate!.toLocal().toString().split(' ')[0]
                  : "No end date",
            ),
            const SizedBox(height: 16),

            // Additional Section (Errands, etc.)
            if (widget.subtask.errands.isNotEmpty) ...[
              _buildSectionTitle("Errands"),
              ...widget.subtask.errands.map((errand) => _buildInfoCard(
                    icon: Icons.check_circle,
                    title: "Errand",
                    content: errand,
                  )),
            ],

            // Status Section
            const SizedBox(height: 16),
            _buildSectionTitle("Status"),
            _buildInfoCard(
              icon: widget.subtask.isCompleted
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              title: "Completed",
              content: widget.subtask.isCompleted ? "Yes" : "No",
            ),
          ],
        ),
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  // Information card widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }
}
