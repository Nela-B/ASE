import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl = 'http://localhost:3000/api/tasks';

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskData),
    );

    if (response.statusCode == 201) {
      print('Task créée avec succès');
    } else {
      print('Erreur: ${response.body}');
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

// Update Task
   Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
  final url = Uri.parse('$baseUrl/$taskId');  

  try {
    // HTTP PUT Request
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(taskData), // taskData to JSON format 
    );

    if (response.statusCode == 200) {
      print("Task updated successfully.");
    } else {
      print("Failed to update task. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Failed to update task');
    }
  } catch (e) {
    print("Error while updating task: $e");
    throw Exception("Error while updating task: $e");
  }
}
}
