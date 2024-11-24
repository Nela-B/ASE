import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/models/subtask_model.dart';
import 'package:ase_project/screens/edit_task_page.dart';
import 'package:ase_project/screens/subtask_detail_page.dart'; 
import 'package:http/http.dart' as http;

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  List<SubTask> subtasks = [];

  @override
  void initState() {
    super.initState();
    _fetchSubtasks();
  }

  // Asynchronous method to fetch subtasks from the API
  Future<void> _fetchSubtasks() async {
    final taskId = widget.task.id; // Fetch subtasks through taskId from the API
    final url = 'http://localhost:3000/api/tasks/$taskId/subtask/list';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse JSON response and convert to SubTask objects
        final data = json.decode(response.body);
        final List<SubTask> fetchedSubtasks = (data['subtasks'] as List)
            .map((subtaskData) => SubTask.fromJson(subtaskData))
            .toList();

        setState(() {
          subtasks = fetchedSubtasks; // Save fetched subtasks to state
        });
      } else {
        throw Exception('Failed to load subtasks');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Edit button, navigate to edit page
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(task: widget.task),
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
            // Overview section
            _buildSectionTitle("Overview"),
            _buildInfoCard(
              icon: Icons.description,
              title: "Description",
              content: widget.task.description ?? "No description provided",
            ),
            _buildInfoCard(
              icon: Icons.priority_high,
              title: "Urgency",
              content: widget.task.urgency,
            ),
            _buildInfoCard(
              icon: Icons.event,
              title: "Due Date",
              content: widget.task.dueDate != null
                  ? widget.task.dueDate!.toLocal().toString().split(' ')[0]
                  : "No due date",
            ),
            _buildInfoCard(
              icon: Icons.verified,
              title: "Importance",
              content: widget.task.importance,
            ),
            _buildInfoCard(
              icon: Icons.star,
              title: "Points",
              content: "${widget.task.points}",
            ),
            const SizedBox(height: 16),

            // Recurrence section
            _buildSectionTitle("Recurrence Details"),
            _buildInfoCard(
              icon: Icons.repeat,
              title: "Frequency",
              content: widget.task.frequency,
            ),
            _buildInfoCard(
              icon: Icons.access_time,
              title: "Interval",
              content: widget.task.interval?.toString() ?? "No interval specified",
            ),
            _buildInfoCard(
              icon: Icons.date_range,
              title: "Recurrence End",
              content: widget.task.recurrenceEndDate != null
                  ? widget.task.recurrenceEndDate!.toLocal().toString().split(' ')[0]
                  : "No end date",
            ),
            const SizedBox(height: 16),

            // Attachments section
            if (widget.task.links != null && widget.task.links!.isNotEmpty) ...[
              _buildSectionTitle("Attachments"),
              ...widget.task.links!.map((link) => _buildAttachmentCard(link)),
            ],
            if (widget.task.filePaths != null && widget.task.filePaths!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle("Files"),
              ...widget.task.filePaths!.map((filePath) => _buildAttachmentCard(filePath)),
            ],

            // Subtasks section
            if (subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionTitle("Subtasks"),
              ...subtasks.map((subtask) => _buildSubtaskCard(subtask, context)),
            ],

            // Completion and status section
            const SizedBox(height: 16),
            _buildSectionTitle("Status"),
            _buildInfoCard(
              icon: widget.task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              title: "Completed",
              content: widget.task.isCompleted ? "Yes" : "No",
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create section title
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

  // Helper method to create information card
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

  // Helper method to create attachment card
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

  // Helper method to create subtask card
  Widget _buildSubtaskCard(SubTask subtask, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
        title: Text(
          subtask.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // Navigate to subtask detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubtaskDetailPage(subtask: subtask),
            ),
          );
        },
      ),
    );
  }
}
