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
  String deadlineType = 'none';  // 'specific', 'today', 'this week', 'none'
  DateTime? dueDate;
  DateTime? dueTime;
  String urgency = 'not urgent';
  String importance = 'not important';
  List<String> links = [];
  List<String> filePaths = [];
  bool notify = false;
  String frequency = 'none';
  int interval = 1;
  List<String> byDay = [];
  int byMonthDay = 1;
  String recurrenceEndType = 'none';
  DateTime? recurrenceEndDate;
  int maxOccurrences = 0;
  int points = 0;

  final linkController = TextEditingController();

  // Frequency, Interval, ByDay, ByMonthDay Widget
  Widget buildFrequencySection() {
    return Column(
      children: [
        // Frequency selection
        DropdownButtonFormField<String>(
          value: frequency,
          decoration: const InputDecoration(labelText: 'Frequency'),
          items: ['daily', 'weekly', 'monthly', 'yearly', 'none']
              .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
              .toList(),
          onChanged: (value) => setState(() => frequency = value!),
        ),
        const SizedBox(height: 10),
        
        // Interval setting
        TextFormField(
          decoration: const InputDecoration(labelText: 'Interval'),
          keyboardType: TextInputType.number,
          initialValue: interval.toString(),
          onChanged: (value) {
            setState(() => interval = int.tryParse(value) ?? 1);
          },
        ),
        const SizedBox(height: 10),
        
        // ByDay (Days of the week)
        TextFormField(
          decoration: const InputDecoration(labelText: 'By Day (Weekdays, e.g., Monday)'),
          onChanged: (value) {
            setState(() {
              byDay = value.split(',').map((e) => e.trim()).toList();
            });
          },
        ),
        const SizedBox(height: 10),
        
        // ByMonthDay (Day of the month)
        TextFormField(
          decoration: const InputDecoration(labelText: 'By Month Day'),
          keyboardType: TextInputType.number,
          initialValue: byMonthDay.toString(),
          onChanged: (value) {
            setState(() => byMonthDay = int.tryParse(value) ?? 1);
          },
        ),
      ],
    );
  }

  // Recurrence End Section
  Widget buildRecurrenceEndSection() {
    return Column(
      children: [
        // Recurrence End Type (End condition)
        DropdownButtonFormField<String>(
          value: recurrenceEndType,
          decoration: const InputDecoration(labelText: 'Recurrence End Type'),
          items: ['never', 'date', 'occurrences', 'none']
              .map((endType) => DropdownMenuItem(value: endType, child: Text(endType)))
              .toList(),
          onChanged: (value) => setState(() => recurrenceEndType = value!),
        ),
        const SizedBox(height: 10),
        
        // Recurrence End Date (End date)
        if (recurrenceEndType == 'date')
          TextFormField(
            decoration: const InputDecoration(labelText: 'Recurrence End Date'),
            readOnly: true,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: recurrenceEndDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                setState(() => recurrenceEndDate = selectedDate);
              }
            },
            controller: TextEditingController(
              text: recurrenceEndDate != null
                  ? recurrenceEndDate!.toLocal().toString().split(' ')[0]
                  : '',
            ),
          ),
        
        // Max Occurrences (Max repetition count)
        if (recurrenceEndType == 'occurrences')
          TextFormField(
            decoration: const InputDecoration(labelText: 'Max Occurrences'),
            keyboardType: TextInputType.number,
            initialValue: maxOccurrences.toString(),
            onChanged: (value) {
              setState(() => maxOccurrences = int.tryParse(value) ?? 0);
            },
          ),
      ],
    );
  }

  Future<void> submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Process dueDate based on deadlineType
    DateTime? combinedDateTime;
    if (deadlineType == 'specific') {
      if (dueDate != null && dueTime != null) {
        combinedDateTime = DateTime(
          dueDate!.year,
          dueDate!.month,
          dueDate!.day,
          dueTime!.hour,
          dueTime!.minute,
        );
      }
    } else if (deadlineType == 'today') {
      DateTime today = DateTime.now();
      combinedDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        dueTime?.hour ?? 0,
        dueTime?.minute ?? 0,
      );
    } else if (deadlineType == 'this week') {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
      DateTime sunday = startOfWeek.add(Duration(days: 6)); // Sunday
      combinedDateTime = DateTime(
        sunday.year,
        sunday.month,
        sunday.day,
        dueTime?.hour ?? 0,
        dueTime?.minute ?? 0,
      );
    }

    final taskData = {
      'title': title,
      'description': description,
      'priority': priority,
      'deadlineType': deadlineType,
      'dueDate': combinedDateTime?.toIso8601String(),
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
        if (dueDate == null) {
          dueDate = DateTime.now();
        }
        dueTime = DateTime(
          dueDate!.year,
          dueDate!.month,
          dueDate!.day,
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
            // Conditional rendering for due date and time based on deadlineType
            if (deadlineType == 'specific') ...[
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
            ],
            if (deadlineType == 'today') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Due date: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
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
            ],
            // Deadline Type selection
            DropdownButtonFormField<String>(
              value: deadlineType,
              decoration: const InputDecoration(labelText: 'Deadline Type'),
              items: ['specific', 'today', 'this week', 'none']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => deadlineType = value!),
            ),
            buildFrequencySection(), // Frequency, Interval, ByDay, ByMonthDay related UI
            buildRecurrenceEndSection(), // Recurrence End condition and End date, count related UI
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
              ...filePaths.map((file) => ListTile(title: Text(file))),
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
