import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:ase_project/models/task_model.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl = 'http://localhost:3000/api/tasks';

  Future<void> createTask(String title, String description, String priority) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'priority': priority,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }
  }


   Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/list'));

    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = json.decode(response.body);
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
