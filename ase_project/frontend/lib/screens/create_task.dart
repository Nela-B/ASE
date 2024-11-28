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
  DateTime? dueDate; // Field for due date
  DateTime? dueTime; // Field for due time (separate from due date)
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
  DateTime? completionDate;

  final linkController = TextEditingController();

  void submitTask() async {
    final taskData = {
      'title': title,
      'description': description,
      'priority': priority,
      'deadlineType': deadlineType,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime?.toIso8601String(), // Including dueTime in task data
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
      'completionDate':completionDate,
    };

  
    await taskService.createTask(taskData);
    Navigator.pop(context);


  // Function to pick the due date
  Future<void> _pickDueDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != dueDate) {
      setState(() {
        dueDate = selectedDate;
      });
    }
  }

  // Function to pick the due time
  Future<void> _pickDueTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dueTime ?? DateTime.now()),
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
              // Due Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dueDate == null ? 'No due date set' : 'Due date: ${dueDate!.toLocal()}'),
                  TextButton(
                    onPressed: _pickDueDate,
                    child: Text('Pick Date'),
                  ),
                ],
              ),
              // Due Time Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dueTime == null ? 'No due time set' : 'Due time: ${dueTime!.toLocal().hour}:${dueTime!.toLocal().minute}'),
                  TextButton(
                    onPressed: _pickDueTime,
                    child: Text('Pick Time'),
                  ),
                ],
              ),
              DropdownButtonFormField(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly', 'monthly', 'yearly', 'custom']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => frequency = value!),
              ),
              if (frequency != 'none')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Interval (e.g., every N days)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(
                          () => interval = int.tryParse(value) ?? 1),
                    ),
                    if (frequency == 'weekly')
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Days of the week (e.g., MO, TU)'),
                        onChanged: (value) => setState(() {
                          byDay = value.split(',').map((day) => day.trim()).toList();
                        }),
                      ),
                    if (frequency == 'monthly')
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Day of the month (1-31)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(
                            () => byMonthDay = int.tryParse(value) ?? 1),
                      ),
                  ],
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                controller: TextEditingController(
                    text: dueDate?.toIso8601String() ?? ''),
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
                onChanged: (value) =>
                    setState(() => points = int.tryParse(value) ?? 0),
              ),
              const SizedBox(height: 20),
              // Attach files section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(allowMultiple: true);

                      if (result != null) {
                        setState(() {
                          filePaths =
                              result.paths.whereType<String>().toList();
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach Files'),
                  ),
                  if (filePaths.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: filePaths.map((path) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            path.split('/').last,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitTask();
                  }
                },
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
}