import 'package:flutter/material.dart';
import 'package:ase_project/models/subtask_model.dart';  
import 'package:ase_project/services/task_service.dart';  

class EditSubtaskPage extends StatefulWidget {
  final SubTask subtask;

  const EditSubtaskPage({super.key, required this.subtask});

  @override
  _EditSubtaskPageState createState() => _EditSubtaskPageState();
}

class _EditSubtaskPageState extends State<EditSubtaskPage> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String description;
  late String urgency;
  late String importance;
  late String frequency;
  late int points;
  DateTime? dueDate;
  DateTime? recurrenceEndDate;

  @override
  void initState() {
    super.initState();
    // Initialize the form fields with the current subtask data
    title = widget.subtask.title;
    description = widget.subtask.description; 
    urgency = widget.subtask.urgency;  
    importance = widget.subtask.importance;  
    frequency = widget.subtask.frequency; 
    points = widget.subtask.points;  
    dueDate = widget.subtask.dueDate;  
    recurrenceEndDate = widget.subtask.recurrenceEndDate; 
  }

  // Method to save the updated subtask
  Future<void> updateSubtask() async {
    final updatedSubtask = {
      'title': title,
      'description': description,
      'urgency': urgency,
      'importance': importance,
      'frequency': frequency,
      'points': points,
      'completed': widget.subtask.isCompleted, 
      'dueDate': dueDate?.toIso8601String(),  
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'errands': widget.subtask.errands, 
    };

    try {
      // Call updateSubTask method from TaskService
      await TaskService().updateSubTask(
        widget.subtask.id, 
        updatedSubtask,  
      );

      // If update is successful, navigate back
      Navigator.pop(context, true);
    } catch (e) {
       print("Error while updating sub-task: $e");  
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update subtask')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subtask'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                updateSubtask(); 
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              // Description Field
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),

              // Urgency Dropdown
              DropdownButtonFormField<String>(
                value: urgency,
                decoration: const InputDecoration(labelText: 'Urgency'),
                items: ['not urgent', 'urgent', 'very urgent']
                    .map((label) => DropdownMenuItem<String>(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => urgency = value!),
              ),

              // Importance Dropdown
              DropdownButtonFormField<String>(
                value: importance,
                decoration: const InputDecoration(labelText: 'Importance'),
                items: ['not important', 'important', 'very important']
                    .map((label) => DropdownMenuItem<String>(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => importance = value!),
              ),

              // Frequency Dropdown
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly', 'monthly', 'yearly', 'custom']
                    .map((label) => DropdownMenuItem<String>(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => frequency = value!),
              ),

              // Points Field
              TextFormField(
                initialValue: points.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points'),
                onChanged: (value) => setState(() => points = int.tryParse(value) ?? 0),
              ),

              // Due Date Field
              TextFormField(
                initialValue: dueDate != null ? dueDate!.toLocal().toString().split(' ')[0] : '', 
                decoration: const InputDecoration(labelText: 'Due Date'),
                onTap: () async {
                final selectedDate = await showDatePicker(
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
                },
              readOnly: true,
              ),

                // Recurrence End Date Field
              TextFormField(
                initialValue: recurrenceEndDate != null ? recurrenceEndDate!.toLocal().toString().split(' ')[0] : '', // 날짜만 표시
                decoration: const InputDecoration(labelText: 'Recurrence End Date'),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: recurrenceEndDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  );
                if (selectedDate != null && selectedDate != recurrenceEndDate) {
                  setState(() {
                  recurrenceEndDate = selectedDate;  
               });
              }
             },
             readOnly: true,
            ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    updateSubtask(); // Save the subtask if the form is valid
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
