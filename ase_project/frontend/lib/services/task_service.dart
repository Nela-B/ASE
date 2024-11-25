import 'dart:convert';
import 'package:ase_project/models/task_model.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl = 'http://localhost:3000/api/tasks';

  // Create a new task
  Future<void> createTask(Map<String, dynamic> taskData) async {
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
      return tasksJson.map((json) => Task.fromJson(json)).toList();
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

  // Calculate daily points for completed tasks
  // Future<Map<DateTime, int>> getDailyPoints() async {
  //   final tasks = await fetchTasks();
  //   final Map<DateTime, int> dailyPoints = {};

  //   for (final task in tasks) {
  //     if (task.isCompleted && task.dueDate != null) {
  //       final date = DateTime(
  //         task.dueDate!.year,
  //         task.dueDate!.month,
  //         task.dueDate!.day,
  //       );
  //       dailyPoints[date] = (dailyPoints[date] ?? 0) + task.points;
  //     }
  //   }

  //   return dailyPoints;
  // }

  // // Calculate accumulated points over time
  // Future<List<int>> getAccumulatedPoints() async {
  //   final tasks = await fetchTasks();
  //   List<int> accumulatedPoints = [];
  //   int totalPoints = 0;
 
  //   for (final task in tasks) {
  //     if (task.isCompleted) {
  //       totalPoints += task.points;
  //       accumulatedPoints.add(totalPoints);
  //     }
  //   }

  //   return accumulatedPoints;
  // }

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


// ----------------------------------------------------------------------------
// CHARTS DATA
// ----------------------------------------------------------------------------

static const String baseUrlChart = 'http://localhost:3000/api/charts';

// Daily Points Data
  // Fetch Daily Points
  Future<Map<String, int>> getDailyPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/daily-points'));
    if (response.statusCode == 200) {
      return Map<String, int>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load daily points');
    }
  }

  // Accumulated Points Data
  Future<List<Map<String, dynamic>>> getAccumulatedPoints() async {
    final response = await http.get(Uri.parse('$baseUrlChart/accumulated-points'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load accumulated points');
    }
  }

  // Weekly Points Data
  Future<Map<int, int>> getWeeklyPoints() async {
  final response = await http.get(Uri.parse('$baseUrlChart/weekly-points'));
  if (response.statusCode == 200) {
    // Parse keys as integers
    final Map<String, dynamic> rawData = json.decode(response.body);
    return rawData.map((key, value) => MapEntry(int.parse(key), value as int));
  } else {
    throw Exception('Failed to load weekly points');
  }
}


  // Monthly Points Data
  Future<Map<int, int>> getMonthlyPoints() async {
  final response = await http.get(Uri.parse('$baseUrlChart/monthly-points'));
  if (response.statusCode == 200) {
    // Parse the raw response and convert keys to integers
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

    // Renvoyer les totaux directement
    return {
      'completedBeforeDueDate': rawData['completedBeforeDueDate'] as int,
      'completedAfterDueDate': rawData['completedAfterDueDate'] as int,
    };
  } else {
    throw Exception('Failed to load comparison data');
  }
}
}