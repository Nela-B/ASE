import 'package:flutter/material.dart';
import '../services/task_service.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTask> {
  final _formKey = GlobalKey<FormState>();
  final TaskService taskService = TaskService();

  String title = '';
  String description = '';
  String priority = 'low';
  String deadlineType = 'specific';
  DateTime? dueDate;
  String urgency = 'not urgent';
  String importance = 'not important';
  List<String> links = [];
  List<String> filePaths = [];
  bool notify = false;
  String frequency = 'daily';
  int interval = 1;
  List<String> byDay = [];
  int byMonthDay = 1;
  String recurrenceEndType = 'never';
  DateTime? recurrenceEndDate;
  int maxOccurrences = 0;
  int points = 0;

  final linkController = TextEditingController();
  final filePathController = TextEditingController();

  void submitTask() async {
    final taskData = {
      'title': title,
      'description': description,
      'priority': priority,
      'deadlineType': deadlineType,
      'dueDate': dueDate?.toIso8601String(),
      'urgency': urgency,
      'importance': importance,
      'links': links,
      'filePaths': filePaths,
      'notify': notify,
      'frequency': frequency,
      'interval': interval,
      'byDay': byDay,
      'byMonthDay': byMonthDay,
      'recurrenceEndType': recurrenceEndType,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'maxOccurrences': maxOccurrences,
      'points': points,
    };

    await taskService.createTask(taskData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) { });

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              DropdownButtonFormField(
                value: frequency,
                decoration: InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly', 'monthly', 'yearly', 'custom']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) => setState(() => frequency = value!),
              ),
              if (frequency != 'none')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Interval (e.g., every N days)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() => interval = int.tryParse(value) ?? 1),
                    ),
                    if (frequency == 'weekly')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Days of the week (e.g., MO, TU)'),
                        onChanged: (value) => setState(() {
                          byDay = value.split(',').map((day) => day.trim()).toList();
                        }),
                      ),
                    if (frequency == 'monthly')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Day of the month (1-31)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => byMonthDay = int.tryParse(value) ?? 1),
                      ),
                    if (frequency == 'custom')
                      Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Custom Interval'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() => interval = int.tryParse(value) ?? 1),
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Custom Frequency (e.g., every N weeks)'),
                            onChanged: (value) => setState(() => frequency = value),
                          ),
                        ],
                      ),
                  ],
                ),
              SwitchListTile(
                title: Text('Notify'),
                value: notify,
                onChanged: (value) => setState(() => notify = value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => points = int.tryParse(value) ?? 0),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitTask();
                  }
                },
                child: Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
