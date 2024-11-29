import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  DateTime? dueTime;
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

  Future<void> submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskData = {
      'title': title,
      'description': description,
      'priority': priority,
      'deadlineType': deadlineType,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime?.toIso8601String(),
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

    try {
      await taskService.createTask(taskData);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickDueDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        dueDate = selectedDate;
      });
    }
  }

  Future<void> _pickDueTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: dueTime != null
          ? TimeOfDay.fromDateTime(dueTime!)
          : TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        dueTime = DateTime(
          dueDate?.year ?? DateTime.now().year,
          dueDate?.month ?? DateTime.now().month,
          dueDate?.day ?? DateTime.now().day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dueDate == null
                      ? 'No due date set'
                      : 'Due date: ${dueDate!.toLocal().toString().split(' ')[0]}'),
                  TextButton(
                    onPressed: _pickDueDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dueTime == null
                      ? 'No due time set'
                      : 'Due time: ${dueTime!.hour}:${dueTime!.minute}'),
                  TextButton(
                    onPressed: _pickDueTime,
                    child: const Text('Pick Time'),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(allowMultiple: true);

                  if (result != null) {
                    setState(() {
                      filePaths = result.paths.whereType<String>().toList();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No files selected')),
                    );
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Files'),
              ),
              if (filePaths.isNotEmpty)
                ...filePaths.map((path) => ListTile(
                      leading: const Icon(Icons.file_present),
                      title: Text(path.split('/').last),
                    )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitTask,
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
