import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/models/subtask_model.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:async';


class TaskService {
  final String baseUrl = 'http://localhost:3000/api/tasks';

  // Create a new task
  Future<void> createTask(Map<String, dynamic> taskData) async {

      // Ensure dueDate is correctly formatted before sending
    if (taskData['dueDate'] != null && taskData['dueDate'] is DateTime) {
      taskData['dueDate'] = taskData['dueDate'].toIso8601String();  // Format DateTime to string
    }

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskData),
    );

    if (response.statusCode == 201) {
      print('Task created successfully');
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to create task');
    }
  }

    // Fetch all tasks
    Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/list'));

    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = json.decode(response.body);

      // This line could be causing the problem
      return tasksJson.map((json) {
        if (json['dueDate'] != null) {
          json['dueDate'] = DateTime.parse(json['dueDate']);  // Parse dueDate string to DateTime
        }
        return Task.fromJson(json);
      }).toList();  // Ensures we return a flat List<Task>
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to load tasks');
    }
  }
  // Update a task with full data
  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    final url = Uri.parse('$baseUrl/$taskId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
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

  // Update task completion status
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    final url = Uri.parse('$baseUrl/$taskId/completed'); // Ensure this matches the backend

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isCompleted': isCompleted}),
      );

      if (response.statusCode == 200) {
        print("Task completion updated successfully.");
      } else {
        print("Failed to update task completion. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to update task completion');
      }
    } catch (e) {
      print("Error while updating task completion: $e");
      throw Exception("Error while updating task completion: $e");
    }
  }

  // Delete a task by ID
  Future<void> deleteTask(String taskId) async {
    final url = Uri.parse('$baseUrl/$taskId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Task deleted successfully.");
      } else {
        print("Failed to delete task. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print("Error while deleting task: $e");
      throw Exception("Error while deleting task: $e");
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
        print('Error: ${response.body}');
        throw Exception('Failed to create sub-task');
      }
    } catch (e) {
      print('Error creating sub-task: $e');
      throw Exception('Error creating sub-task: $e');
    }
  }

  // Fetch Subtasks
  Future<List<SubTask>> fetchSubTasks(String taskId) async {
    final url = Uri.parse('$baseUrl/$taskId/subtask/list');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);
        return responseBody.map((item) => SubTask.fromJson(item)).toList();
      } else {
        print('Failed to fetch subtasks. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch subtasks');
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
      print('Subtask updated successfully');
    } else {
      throw Exception('Failed to update subtask');
    }
  }

  // Delete Subtask
  Future<void> deleteSubTask(String subtaskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/subtask/$subtaskId'),
      );

      if (response.statusCode == 200) {
        print('Subtask deleted successfully');
      } else {
        print('Failed to delete subtask. Status code: ${response.statusCode}');
        throw Exception('Failed to delete subtask');
      }
    } catch (e) {
      print('Error deleting subtask: $e');
      throw Exception('Error deleting subtask: $e');
    }
  }

  // Charts Data
  final String baseUrlChart = 'http://localhost:3000/api/charts';


  Future<Map<String, int>> getDailyPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/daily-points'));
    if (response.statusCode == 200) {
      // Convertir les données JSON en Map<String, int>
      return Map<String, int>.from(json.decode(response.body));
    } else {
      print('Failed to fetch daily points. Status: ${response.statusCode}');
      throw Exception('Failed to load daily points');
    }
  }


  Future<Map<int, int>> getWeeklyPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/weekly-points'));
    if (response.statusCode == 200) {
      // Convertir les clés JSON en entiers
      final Map<String, dynamic> rawData = json.decode(response.body);
      return rawData.map((key, value) => MapEntry(int.parse(key), value as int));
    } else {
      print('Failed to fetch weekly points. Status: ${response.statusCode}');
      throw Exception('Failed to load weekly points');
    }
  }


  Future<List<Map<String, dynamic>>> getAccumulatedPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/accumulated-points'));
    if (response.statusCode == 200) {
      // La réponse doit être une liste d'objets JSON
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      // Gestion des erreurs
      print('Failed to fetch accumulated points. Status: ${response.statusCode}');
      throw Exception('Failed to load accumulated points');
    }
  }


  // Monthly Points Data
  Future<Map<int, int>> getMonthlyPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/monthly-points'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawData = json.decode(response.body);
      return rawData.map((key, value) => MapEntry(int.parse(key), value as int));
    } else {
      throw Exception('Failed to load monthly points');
    }
  }

  // Comparison Data
  Future<Map<String, int>> getComparisonData() async {
    final response = await http.get(Uri.parse('$baseUrlChart/tasks-completion'));
    if (response.statusCode == 200) {
      final rawData = json.decode(response.body);
      return {
        'completedBeforeDueDate': rawData['completedBeforeDueDate'] as int,
        'completedAfterDueDate': rawData['completedAfterDueDate'] as int,
      };
    } else {
      throw Exception('Failed to load comparison data');
    }
  }


Future<List<Task>> restoreTasks(String backupPath) async {
  final url = Uri.parse('$baseUrl/restore'); // Restore API endpoint

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'backupPath': backupPath}), // Include backup path
    );

    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = json.decode(response.body);

      return tasksJson.map((json) {
        if (json['dueDate'] != null) {
          json['dueDate'] = DateTime.parse(json['dueDate']);
        }
        return Task.fromJson(json);
      }).toList();
    } else {
      throw Exception('Failed to restore tasks');
    }
  } catch (e) {
    throw Exception('Error while restoring tasks: $e');
  }
}

Future<List<Task>> restoreTasksFromFile(html.File file) async {
  final url = Uri.parse('$baseUrl/restore'); // Server restore API endpoint

  // Handling the function to return a Future
  return await _uploadFileAndRestoreTasks(file, url);
}

// Actual logic to upload the file and restore tasks
Future<List<Task>> _uploadFileAndRestoreTasks(html.File file, Uri url) async {
  try {
    // Create a FormData object
    var formData = html.FormData();
    formData.appendBlob('backupFile', file); // Upload matching the 'backupFile' field name

    // Upload the file and wait for a response
    final completer = Completer<List<Task>>();  // Create a Completer to wait for the response

    // Use HttpRequest object to upload the file
    final request = html.HttpRequest();
    request.open('POST', url.toString(), async: true);

    // Handle response after file upload
    request.onLoadEnd.listen((e) {
      String responseText = request.responseText ?? '';  // Handle null as empty string

      if (request.status == 200) {
        try {
          // Check the received JSON data from the server
          var jsonResponse = json.decode(responseText);

          // Assume the server response includes a 'tasks' array in the object
          List tasksJson = jsonResponse['tasks'] ?? [];  // Extract the tasks array

          // Complete the completer when the response is ready
          completer.complete(
            tasksJson.map((task) {
              if (task['dueDate'] != null) {
                task['dueDate'] = DateTime.parse(task['dueDate']);  // Convert 'dueDate' to DateTime if present
              }
              return Task.fromJson(task);  // Convert to Task object
            }).toList()
          );
        } catch (e) {
          completer.completeError('Error parsing server response');
        }
      } else {
        completer.completeError('Error restoring from the server');
      }
    });

    // Send the file to the server
    request.send(formData);

    // Wait for the completer to finish and return the result
    return await completer.future;

  } catch (e) {
    throw Exception('Error during file restoration: $e');
  }
}

  
}
