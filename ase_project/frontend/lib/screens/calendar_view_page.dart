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
  late Map<DateTime, List<Map<String, String>>> _events; // Map to store events for each day
  late List<Map<String, String>> _selectedEvents; // List to store events for the selected date
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
      Map<DateTime, List<Map<String, String>>> events = {};

      for (var task in tasks) {
        if (task['dueDate'] != null) {
          DateTime dueDate = DateTime.parse(task['dueDate']).toLocal();
          DateTime normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

          if (events[normalizedDueDate] == null) {
            events[normalizedDueDate] = [];
          }
          events[normalizedDueDate]?.add({
            'title': task['title'] ?? 'Untitled Task',
            'description': task['description'] ?? 'No description',
          });
        }
      }

      setState(() {
        _events = events;
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Get tasks for a specific day
  List<Map<String, String>> _getEventsForDay(DateTime day) {
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
            eventLoader: (day) => _getEventsForDay(day).map((e) => e['title']).toList(),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                // Default marker builder (dots)
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 6.0,
                          height: 6.0,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                final taskTitles = _getEventsForDay(day).map((e) => e['title']).toList();
                if (taskTitles.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...taskTitles.map((title) {
                          return Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }).take(2), // Show up to 2 task titles
                      ],
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(child: Text('No tasks for this day.'))
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final task = _selectedEvents[index];
                      return ListTile(
                        title: Text(task['title'] ?? 'No Title'),
                        subtitle: Text(task['description'] ?? 'No Description'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
