import 'package:flutter/material.dart';
import 'package:ase_project/models/task_model.dart';
import 'package:ase_project/services/task_service.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TaskService taskService = TaskService();

  late String title;
  late String description;
  late String urgency;
  late String importance;
  late String frequency;
  late int interval;
  late List<String> byDay;
  late int byMonthDay;
  late int points;
  late bool notify;

  late String customFrequency;
  late int customInterval;

  @override
  void initState() {
    super.initState();
    // Initialize with the existing task data
    title = widget.task.title;
    description = widget.task.description ?? '';
    urgency = widget.task.urgency;
    importance = widget.task.importance;
    frequency = widget.task.frequency;
    interval = widget.task.interval!;
    byDay = widget.task.byDay!;
    byMonthDay = widget.task.byMonthDay!;
    points = widget.task.points;
    notify = widget.task.notify;
    
    // Initialize custom fields based on the task data
    customFrequency = widget.task.frequency == 'custom' ? widget.task.frequency : '';
    customInterval = widget.task.interval!;
  }

  // Task update function
  void updateTask() async {
    // Create an updated task with the modified data
    final updatedTask = Task(
      id: widget.task.id,
      title: title,
      description: description,
      deadlineType: widget.task.deadlineType,
      dueDate: widget.task.dueDate,
      isCompleted: widget.task.isCompleted,
      urgency: urgency,
      importance: importance,
      links: widget.task.links,
      filePaths: widget.task.filePaths,
      notify: notify,
      frequency: frequency == 'custom' ? customFrequency : frequency, // handle custom frequency
      interval: frequency == 'custom' ? customInterval : interval, // handle custom interval
      byDay: byDay,
      byMonthDay: byMonthDay,
      recurrenceEndType: widget.task.recurrenceEndType,
      recurrenceEndDate: widget.task.recurrenceEndDate,
      maxOccurrences: widget.task.maxOccurrences,
      points: points,
    );

    // Update the task in the database
    try {
      await taskService.updateTask(widget.task.id!, updatedTask.toJson());
      Navigator.pop(context, true); // Return to the previous screen after update
    } catch (e) {
      print("Error while updating task: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An error occurred while updating the task."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Task Title
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter a title';
                  }
                  return null;
                },
              ),

              // Task Description
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),

              // Task Urgency Dropdown
              DropdownButtonFormField<String>(
                value: urgency,
                decoration: const InputDecoration(labelText: 'Urgency'),
                items: ['not urgent', 'urgent', 'very urgent']
                    .map((label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => urgency = value!),
              ),

              // Task Importance Dropdown
              DropdownButtonFormField<String>(
                value: importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: ['not important', 'important', 'very important']
                    .map((label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => importance = value!),
              ),

              // Task Frequency Dropdown
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly', 'monthly', 'yearly', 'custom']
                    .map((label) => DropdownMenuItem<String>(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  frequency = value!;
                  if (frequency != 'custom') {
                    customFrequency = '';
                    customInterval = 1;
                  }
                }),
              ),

              // Interval field (e.g., "every X days")
              TextFormField(
                initialValue: interval.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Interval'),
                onChanged: (value) => setState(() => interval = int.tryParse(value) ?? 1),
              ),

              // Custom frequency section (only shown if the frequency is custom)
              if (frequency == 'custom') ...[
                // Custom Interval
                TextFormField(
                  initialValue: customInterval.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Custom Interval'),
                  onChanged: (value) => setState(() => customInterval = int.tryParse(value) ?? 1),
                ),
                // Custom Frequency Description
                TextFormField(
                  initialValue: customFrequency,
                  decoration: const InputDecoration(labelText: 'Custom Frequency (e.g., every N weeks)'),
                  onChanged: (value) => setState(() => customFrequency = value),
                ),
              ],

              // If the frequency is weekly, show a field to select the days
              if (frequency == 'weekly')
                TextFormField(
                  initialValue: byDay.join(', '),
                  decoration: const InputDecoration(labelText: 'Days of the week (e.g., MO, TU)'),
                  onChanged: (value) => setState(() {
                    byDay = value.split(',').map((day) => day.trim()).toList();
                  }),
                ),

              // If the frequency is monthly, show a field to specify the day of the month
              if (frequency == 'monthly')
                TextFormField(
                  initialValue: byMonthDay.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Day of the month (1-31)'),
                  onChanged: (value) => setState(() => byMonthDay = int.tryParse(value) ?? 1),
                ),

              // Task Points field with validation
              TextFormField(
                initialValue: points.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points'),
                onChanged: (value) {
                  setState(() {
                    points = int.tryParse(value) ?? 0; // Fallback to 0 if invalid
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter points';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Points must be a valid number';
                  }
                  return null;
                },
              ),

              // Notify switch
              SwitchListTile(
                title: const Text('Notify'),
                value: notify,
                onChanged: (value) => setState(() => notify = value),
              ),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateTask();
                  }
                },
                child: const Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
