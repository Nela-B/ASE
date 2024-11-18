import 'package:ase_project/components/task_card.dart';
import 'package:ase_project/screens/create_task.dart';
import 'package:ase_project/screens/task_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ase_project/models/task_model.dart';


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

  void _onRightButtonPressed() {
    // Define action for the right button
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
          ? Center(child: CircularProgressIndicator())
          :ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (context, index) {
    return TaskCard(
      task: tasks[index],
      onTap: () {
        print("Task tapped: ${tasks[index].title}");
        _navigateToTaskDetails(tasks[index]);
      },
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTask,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.list),
                  onPressed: _onLeftButtonPressed,
                ),
                SizedBox(width: 48), // Space for the central FAB
                IconButton(
                  icon: Icon(Icons.logout),
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
