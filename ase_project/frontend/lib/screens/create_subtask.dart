import 'package:flutter/material.dart';
import '../services/task_service.dart';

class CreateSubTask extends StatefulWidget {
  final String taskId;

  const CreateSubTask({super.key, required this.taskId});

  @override
  _CreateSubTaskPageState createState() => _CreateSubTaskPageState();
}

class _CreateSubTaskPageState extends State<CreateSubTask> {
  final _formKey = GlobalKey<FormState>();
  final TaskService taskService = TaskService();

  // SubTask related fields
  String title = '';
  String description = '';
  String deadlineType = 'specific';
  DateTime? dueDate;
  String urgency = 'not urgent';
  String importance = 'not important';
  List<String> links = [];
  List<String> filePaths = [];
  bool notify = false;
  String frequency = 'daily'; // Default to 'daily'
  int interval = 1;
  List<String> byDay = [];
  int byMonthDay = 1;
  String recurrenceEndType = 'never';
  DateTime? recurrenceEndDate;
  int maxOccurrences = 0;
  int points = 0;

  final linkController = TextEditingController();
  final filePathController = TextEditingController();

  // Function to submit the subtask
  void submitSubTask() async {
    // Validate the form to ensure all required fields are filled
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prepare the subtask data to send to the server
    final subTaskData = {
      'title': title,
      'description': description,
      'deadlineType': deadlineType,
      'dueDate': dueDate?.toIso8601String(),
      'urgency': urgency,
      'importance': importance,
      'links': links,  // links field is not used yet but send as an array
      'filePaths': filePaths,  // filePaths field is also sent as an array
      'notify': notify,
      'frequency': frequency, // frequency field (daily, weekly, monthly, yearly, etc.)
      'interval': interval,
      'byDay': byDay,  // byDay array (e.g., ['Monday', 'Tuesday'])
      'byMonthDay': byMonthDay,  // byMonthDay number
      'recurrenceEndType': recurrenceEndType, // recurrenceEndType (never, date, occurrences, etc.)
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),  // recurrenceEndDate (nullable)
      'maxOccurrences': maxOccurrences,  // maxOccurrences (maximum occurrences)
      'points': points,  // points field
    };

    try {
      await taskService.createSubTask(widget.taskId, subTaskData);  // Request to add subtask to the server
      print("Sub-task added successfully");
      Navigator.pop(context);  // Close the screen after successful creation
    } catch (e) {
      print("Error adding sub-task: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding subtask: $e')));
      return; // Exit the function if an error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create SubTask'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              DropdownButtonFormField(
                value: deadlineType,
                decoration: const InputDecoration(labelText: 'Deadline Type'),
                items: ['specific', 'today', 'this week', 'none']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => deadlineType = value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                controller: TextEditingController(text: dueDate?.toIso8601String()),
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() => dueDate = selectedDate);
                  }
                },
              ),
              DropdownButtonFormField(
                value: urgency,
                decoration: const InputDecoration(labelText: 'Urgency'),
                items: ['urgent', 'not urgent']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => urgency = value!),
              ),
              DropdownButtonFormField(
                value: importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: ['important', 'not important']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => importance = value!),
              ),
              SwitchListTile(
                title: const Text('Notify'),
                value: notify,
                onChanged: (value) => setState(() => notify = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => points = int.tryParse(value) ?? 0),
              ),
              ElevatedButton(
                onPressed: submitSubTask, // Submit subtask
                child: const Text('Create SubTask'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
