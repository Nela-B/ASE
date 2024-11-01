import 'dart:convert';
// ignore: depend_on_referenced_packages
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
}
