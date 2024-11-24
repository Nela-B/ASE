import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/models/subtask_model.dart';
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

// Delete Task
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$taskId'),
      );

      if (response.statusCode == 200) {
        print('Task deleted successfully');
      } else if (response.statusCode == 404) {
        print('Task not found');
      } else {
        print('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Create Subtask
  Future<void> createSubTask(String taskId, Map<String, dynamic> subTaskData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$taskId/subtasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(subTaskData),
      );
      if (response.statusCode == 201) {
        print('Sub-task created successfully');
      } else {
        // Print error message returned by the server
        print('Error: ${response.body}');
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('error')) {
            print('Error details: ${responseBody['error']}');
          } else {
            print('Error message: ${responseBody['message']}');
          }
        } catch (e) {
          print('Failed to parse error response: $e');
        }
      }
    } catch (e) {
      print('Error creating sub-task: $e');
    }
  }

  // Fetch Subtasks
  Future<List<SubTask>> fetchSubTasks(String taskId) async {
    final url = Uri.parse('$baseUrl/$taskId/subtask/list');

    // Define request headers
    final headers = {
      'Content-Type': 'application/json',
    };

    // Define request body (if necessary)
    final body = json.encode({'task_id': taskId});

    print('URL for request: $url'); // Print URL for request

    try {
      // Send POST request
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        print('Subtask response: $responseBody'); // Print response content

        // Check if response data is in List format
        if (responseBody is List) {
          // Convert each item to SubTask object
          return responseBody.map((item) => SubTask.fromJson(item)).toList();
        } else {
          print('Response data is different from expected: $responseBody');
          return [];
        }
      } else {
        print('Failed to fetch subtasks. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch subtasks: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while fetching subtasks: $e');
      throw Exception("Error occurred while fetching subtasks: $e");
    }
  }

  // Update Subtask
  Future<void> updateSubTask(String subtaskId, Map<String, dynamic> updatedSubtask) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subtasks/$subtaskId'),
      body: json.encode(updatedSubtask),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successfully updated
      print('Subtask updated successfully');
    } else {
      // Handle failure response from server
      throw Exception('Failed to update subtask');
    }
  }

  // Delete Subtask
  Future<void> deleteSubTask(String subtaskId) async {
    try {
      print('Attempting to delete subtask with ID: $subtaskId'); 
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/subtask/$subtaskId'),
      );

      if (response.statusCode == 200) {
        print('Subtask deleted successfully');
      } else if (response.statusCode == 404) {
        print('Subtask not found');
      } else {
        print('Failed to delete subtask: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting subtask: $e');
    }
  }
  
}
