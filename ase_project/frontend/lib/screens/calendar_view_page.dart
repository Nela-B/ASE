import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarViewPage extends StatefulWidget {
  const CalendarViewPage({super.key});

  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  late Map<DateTime, List<String>> _events; // Map to store events for each day
  late List<String> _selectedEvents; // List to store events for the selected date
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchTasks(); // Fetch tasks on page load
  }

  // Fetch tasks from the backend
  Future<void> _fetchTasks() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/tasks/list')); // Replace with your actual backend URL

    if (response.statusCode == 200) {
      List<dynamic> tasks = json.decode(response.body);
      Map<DateTime, List<String>> events = {};

      for (var task in tasks) {
        // If the task has a dueDate, add it to the calendar
        if (task['dueDate'] != null) {
          DateTime dueDate = DateTime.parse(task['dueDate']).toLocal();
          // Normalize the time to avoid any time zone issues
         DateTime normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

          if (events[normalizedDueDate] == null) {
            events[normalizedDueDate] = [];
          }
          events[normalizedDueDate]?.add(task['title']);
        }
      }

      setState(() {
        _events = events;
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Get the tasks for the selected day
  List<String> _getEventsForDay(DateTime day) {
    // Normalize the selected day to avoid time zone issues
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Handle day selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2025),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            onPageChanged: (focusedDay) {
              // No need to change selected day when page changes
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8.0),
          ..._selectedEvents.isEmpty
              ? [Text('No tasks for this day.')]
              : _selectedEvents.map((event) => ListTile(title: Text(event))),
        ],
      ),
    );
  }
}
