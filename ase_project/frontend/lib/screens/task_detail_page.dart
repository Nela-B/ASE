import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/screens/edit_task_page.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Edit button to navigate to the edit page
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(task: task),
                ),
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
              content: task.description ?? "No description provided",
            ),
            _buildInfoCard(
              icon: Icons.priority_high,
              title: "Urgency",
              content: task.urgency,
            ),
            _buildInfoCard(
              icon: Icons.event,
              title: "Due Date",
              content: task.dueDate != null
                  ? task.dueDate!.toLocal().toString().split(' ')[0]
                  : "No due date",
            ),
            _buildInfoCard(
              icon: Icons.verified,
              title: "Importance",
              content: task.importance,
            ),
            _buildInfoCard(
              icon: Icons.star,
              title: "Points",
              content: "${task.points}",
            ),
            const SizedBox(height: 16),

            // Recurrence Section
            _buildSectionTitle("Recurrence Details"),
            _buildInfoCard(
              icon: Icons.repeat,
              title: "Frequency",
              content: task.frequency,
            ),
            _buildInfoCard(
              icon: Icons.access_time,
              title: "Interval",
              content: task.interval?.toString() ?? "No interval specified",
            ),
            _buildInfoCard(
              icon: Icons.date_range,
              title: "Recurrence End",
              content: task.recurrenceEndDate != null
                  ? task.recurrenceEndDate!.toLocal().toString().split(' ')[0]
                  : "No end date",
            ),
            const SizedBox(height: 16),

            // Attachments Section
            if (task.links != null && task.links!.isNotEmpty) ...[
              _buildSectionTitle("Attachments"),
              ...task.links!.map((link) => _buildAttachmentCard(link)),
            ],
            if (task.filePaths != null && task.filePaths!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle("Files"),
              ...task.filePaths!
                  .map((filePath) => _buildAttachmentCard(filePath))
                  ,
            ],

            // Completion and Status
            const SizedBox(height: 16),
            _buildSectionTitle("Status"),
            _buildInfoCard(
              icon: task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              title: "Completed",
              content: task.isCompleted ? "Yes" : "No",
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method: Section Title
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

  // Helper Method: Info Card
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

  // Helper Method: Attachment Card
  Widget _buildAttachmentCard(String attachment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.attach_file, color: Colors.green),
        title: Text(
          attachment,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // Add functionality to open the link or file
          print("Tapped on attachment: $attachment");
        },
      ),
    );
  }
}
