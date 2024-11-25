import 'package:ase_project/components/task_card.dart';
import 'package:ase_project/screens/calendar_view_page.dart';
import 'package:ase_project/screens/create_task.dart';
import 'package:ase_project/screens/stat_page.dart';
import 'package:ase_project/screens/task_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'create_subtask.dart';


class HomePage extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Task> tasks = [];

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/tasks/list'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            tasks = jsonResponse.map((task) => Task.fromJson(task)).toList();
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

   // Confirmation popup before deletion
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

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void _navigateToCreateTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTask()),
    );
  }

  void _onLeftButtonPressed() {
    // Define action for the left button
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
    appBar: AppBar(title: Text('Welcome ' + user.email!)),
    body: tasks.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index]; 
              return TaskCard(
                task: task,
                onTap: () {
                  print("Task tapped: ${task.title}");
                  _navigateToTaskDetails(task);
                },
                onDelete: () => _showDeleteDialog(task.id ?? ''), 
                onCreateSubTask: () {
                  if (task.id != null && task.id!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateSubTask(taskId: task.id!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task ID is missing, cannot create subtask'),
                      ),
                    );
                  }
                },
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
