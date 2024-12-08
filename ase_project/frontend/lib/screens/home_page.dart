import 'package:ase_project/components/task_card.dart';
import 'package:ase_project/screens/calendar_view_page.dart';
import 'package:ase_project/screens/create_task.dart';
import 'package:ase_project/screens/stat_page.dart';
import 'package:ase_project/screens/task_detail_page.dart';
import 'package:ase_project/screens/trip_planner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'create_subtask.dart';
import 'dart:io';
import 'package:ase_project/services/task_service.dart';
import 'package:file_picker/file_picker.dart';


class HomePage extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Task> tasks = [];
  String sortCriteria = "dueDate";

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/tasks/list'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            tasks = jsonResponse.map((task) => Task.fromJson(task)).toList();
            _sortTasks();
          });
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/tasks/delete/$taskId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tasks.removeWhere((task) => task.id == taskId);
        });
      } else {
        print('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _refreshTaskWithSubtasks(Task task) async {
  try {
    final updatedSubtasks = await TaskService().fetchSubTasks(task.id!);

    setState(() {
      task.subTasks = updatedSubtasks; // Mettre à jour localement les sous-tâches
    });
  } catch (e) {
    print('Error refreshing task with subtasks: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to refresh subtasks.')),
    );
  }
}


  void _showDeleteDialog(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

 List<Task> selectedTasks = [];

  Future<void> _backupTasks(BuildContext context) async {
    try {
      // If no tasks are selected, backup all tasks, otherwise, backup selected tasks

      List<Task> tasksToBackup = selectedTasks.isEmpty ? tasks : selectedTasks;

      if (tasksToBackup.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tasks to backup.')),
        );
        return;
      }

      // Convert tasks to JSON (no subtasks involved now)
      final taskJsonList = tasksToBackup.map((task) {
        return task.toJson(); // Convert each task to JSON
      }).toList();

      final taskJsonString =
          json.encode(taskJsonList); // Convert list to JSON string

      // Handle backup to local file system for mobile/desktop environments
      final directory = Directory.current;
      final backupDir = Directory('${directory.path}/lib/backup');

      // Ensure the backup directory exists
      if (!await backupDir.exists()) {
        await backupDir.create(
            recursive: true); // Create directory if it doesn't exist
      }

      // Generate a unique filename based on the current time and selection type
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${selectedTasks.isEmpty ? 'tasks' : 'selected_tasks'}_backup_$timestamp.json';
      final filePath = '${backupDir.path}/$fileName';
      final file = File(filePath);

      // Save JSON data to the file
      await file.writeAsString(taskJsonString);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tasksToBackup.length} task(s) backed up locally!'),
        ),
      );

      print('Backup completed for ${tasksToBackup.length} task(s).');
    } catch (e) {
      // Handle any error during backup
      print('Error during backup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during backup.')),
      );
    }
  }

// Function to toggle task selection
  void _toggleTaskSelection(Task task) {
    setState(() {
      if (selectedTasks.contains(task)) {
        selectedTasks.remove(task); // Deselect if already selected
      } else {
        selectedTasks.add(task); // Select if not already selected
      }
    });
  }

   Future<void> _restoreTasks() async {
  try {
    // Show file picker UI
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      // type: FileType.custom,
      // allowedExtensions: ['json', 'JSON'],
    );

    if (result == null) {
      // If no file was selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected for restore.')),
      );
      return;
    }

    // Get the selected file path
    String? backupFilePath = result.files.single.path;

    if (backupFilePath == null) {
      // If the file path is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid file path')),
      );
      return;
    }

    // Restore from the selected file
    try {
      List<Task> restoredTasks =
          await TaskService().restoreTasks(backupFilePath);

      setState(() {
        tasks = restoredTasks; // Update task list with restored tasks
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks restored successfully!')),
      );
    } catch (e) {
      // Error during restore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring from file: $e')),
      );
    }
  } catch (e) {
    print('Error during restore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error during restore.')),
    );
  }
}


  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> _navigateToCreateTask() async {
    final newTask = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CreateTask()),
  );

  if (newTask != null) {
    setState(() {
      tasks.add(Task.fromJson(newTask)); // Ajoute la nouvelle tâche à la liste
      _sortTasks(); // Trie les tâches selon le critère actuel
    });
  }
}
  

  void _onLeftButtonPressed() {
    // Define action for the left button
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripPlannerPage()),
    );
  }

  void _calendarButtonPressed() {
    // Navigate to calendar view
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarViewPage()),
    );
  }

  void _statButtonPressed() {
    // Navigate to stat page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatPage()),
    );
  }

  void _onRightButtonPressed() {
    signUserOut();
  }

   // sign user out method
  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }


  void _sortTasks() {
    if (sortCriteria == "dueDate") {
      tasks.sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
    } else if (sortCriteria == "urgency") {
      tasks.sort((a, b) => (b.urgency).compareTo(a.urgency));
    }
    setState(() {});
  }

  void _toggleSortCriteria() {
    setState(() {
      sortCriteria = (sortCriteria == "dueDate") ? "urgency" : "dueDate";
      _sortTasks();
    });
  }

  void _toggleTaskCompletion(Task task, bool isCompleted) {
    setState(() {
      task.isCompleted = isCompleted;
    });

    _updateTaskCompletionOnServer(task);
  }

  Future<void> _updateTaskCompletionOnServer(Task task) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/tasks/${task.id}/completed'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isCompleted': task.isCompleted}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task completion');
      }
    } catch (e) {
      print('Error updating task completion: $e');
    }
  }

  void _navigateToTaskDetails(Task task) {
    print("Navigating to details of task: ${task.title}");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
    );
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Welcome ' + user.email!),
      actions: [
        IconButton(
          icon: Icon(sortCriteria == "dueDate" ? Icons.date_range : Icons.priority_high),
          tooltip: sortCriteria == "dueDate" ? "Sort by Urgency" : "Sort by Due Date",
          onPressed: _toggleSortCriteria,
        ), IconButton( 
            icon: Icon(Icons.backup),
            tooltip: "Task Backup",
            onPressed: () => _backupTasks(context),
          ), 
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: "Task Restore",
            onPressed: _restoreTasks,
          ),
      ],
    ),
    body: tasks.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
  key: ValueKey(task.id), // Ensure proper rebuilds
  task: task,
  onTap: () {
    print("Task tapped: ${task.title}");
    _navigateToTaskDetails(task);
  },
  onDelete: () => _showDeleteDialog(task.id ?? ''),
  onCreateSubTask: () async {
  if (task.id != null && task.id!.isNotEmpty) {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSubTask(taskId: task.id!),
      ),
    );

    if (result != null && result == true) {
      await _refreshTaskWithSubtasks(task); // Rafraîchit les sous-tâches
    }
  }
},
  onCompletionToggle: (isCompleted) => _toggleTaskCompletion(task, isCompleted), // Ajoutez cette ligne !
);

            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToCreateTask,
      child: const Icon(Icons.add),
      backgroundColor: Theme.of(context).primaryColor,
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: LayoutBuilder(
      builder: (context, constraints) {
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: _onLeftButtonPressed,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _calendarButtonPressed,
              ),
              const SizedBox(width: 48), // Space for the central FAB
              IconButton(
                icon: const Icon(Icons.stacked_bar_chart),
                onPressed: _statButtonPressed,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _onRightButtonPressed,
              ),
            ],
          ),
        );
      },
    ),
  );
}
}
