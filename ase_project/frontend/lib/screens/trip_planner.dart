import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TripPlannerPage extends StatefulWidget {
  @override
  _TripPlannerPageState createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final TaskService taskService = TaskService();
  final TextEditingController destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  Future<void> createTripPlan() async {
    if (destinationController.text.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    String destination = destinationController.text;

    // Prepare subtasks
    List<Map<String, dynamic>> subtasks = [
      {
        'title': "Pack t-shirts",
        'description': "Pack enough t-shirts for the trip.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 6)).toIso8601String(),
        'isCompleted': false,
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never', 
      },
      {
        'title': "Pack pants",
        'description': "Pack enough pants for the trip.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 6)).toIso8601String(),
        'isCompleted': false,
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
      },
      {
        'title': "Check passport validity",
        'description': "Ensure passport is valid for at least 6 months.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 20)).toIso8601String(),
        'isCompleted': false,
        'urgency': "urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
      },
      {
        'title': "Book flight tickets",
        'description': "Search and book the best flights to $destination.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 18)).toIso8601String(),
        'isCompleted': false,
        'urgency': "urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
      },
      {
        'title': "Search for hotels",
        'description': "Find the best hotels in $destination.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 12)).toIso8601String(),
        'isCompleted': false,
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
      },
      {
        'title': "Book hotel",
        'description': "Reserve the best hotel for the trip.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 10)).toIso8601String(),
        'isCompleted': false,
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
      },
    ];

    // Create main tasks with subtasks
    List<Map<String, dynamic>> tasks = [
      {
        'title': "Prepare Luggage",
        'description': "Pack all necessary items for the trip.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 7)).toIso8601String(),
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
        'subTasks': subtasks.where((subtask) => subtask['title']!.contains('Pack')).toList(),
      },
      {
        'title': "Prepare for Flight",
        'description': "Complete all necessary preparations for the flight.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 14)).toIso8601String(),
        'urgency': "urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
        'subTasks': subtasks.where((subtask) => subtask['title']!.contains('passport') || subtask['title']!.contains('flight')).toList(),
      },
      {
        'title': "Book Accommodation",
        'description': "Find and book suitable accommodation for the trip.",
        'deadlineType': "specific",
        'dueDate': startDate!.subtract(Duration(days: 10)).toIso8601String(),
        'urgency': "not urgent",
        'importance': "important",
        'frequency':"none",
        'recurrenceEndType': 'never',
        'subTasks': subtasks.where((subtask) => subtask['title']!.contains('hotel')).toList(),
      },
    ];

    try {
      for (var task in tasks) {
        await taskService.createTask(task); // Send each task payload to the backend
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tasks and subtasks created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create tasks: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trip Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) setState(() => startDate = date);
                    },
                    child: Text(
                      startDate == null
                          ? 'Select start date'
                          : 'Start: ${startDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) setState(() => endDate = date);
                    },
                    child: Text(
                      endDate == null
                          ? 'Select end date'
                          : 'End: ${endDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createTripPlan,
              child: Text('Generate Trip Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
