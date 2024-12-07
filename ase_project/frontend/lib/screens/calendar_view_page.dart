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
  late Map<DateTime, List<Map<String, String>>> _events;
  late List<Map<String, String>> _selectedEvents;
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
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/tasks/list'));

    if (response.statusCode == 200) {
      List<dynamic> tasks = json.decode(response.body);
      Map<DateTime, List<Map<String, String>>> events = {};

      print("Received tasks: $tasks");

      for (var task in tasks) {
        DateTime? dueDate;

        // Use the received dueDate from the server if available
        if (task['dueDate'] != null) {
          // Use the received date as is (without converting to local timezone)
          dueDate = DateTime.parse(task['dueDate']);
        } else {
          // If no dueDate, set it to the current date by default
          dueDate = DateTime.now(); // Set to today's date by default
        }

        // Avoid modifying past dates
        if (dueDate.isBefore(DateTime.now())) {
          // Leave past dates unchanged (do not modify)
        } else {
          // For non-past dates, use them as they are
          dueDate = dueDate; // Use the original date as is
        }

        DateTime normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        String dueTime = "${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}";

        // Add a normal task event
        if (!events.containsKey(normalizedDueDate)) {
          events[normalizedDueDate] = [];
        }
        events[normalizedDueDate]?.add({
          'title': task['title'] ?? 'Untitled Task',
          'description': task['description'] ?? 'No description',
          'dueTime': dueTime,
          'type': 'normal', // Mark as a normal task
        });

        print("Added task: ${task['title']} on $normalizedDueDate");

        int interval = task['interval'] != null ? task['interval'] : 1;

        // Handle recurring tasks
        String frequency = task['frequency'] ?? 'none';
        if (frequency != 'none') {
          DateTime? recurrenceEndDate = task['recurrenceEndDate'] != null
              ? DateTime.parse(task['recurrenceEndDate'])
              : null;
          int maxOccurrences = task['maxOccurrences'] ?? 0;
          String recurrenceEndType = task['recurrenceEndType'] ?? 'none';

          _addRecurringEvents(
            events,
            normalizedDueDate,
            frequency,
            task['title'],
            task['description'],
            dueTime,
            recurrenceEndDate,
            maxOccurrences,
            recurrenceEndType,
            interval,
          );
        }
      }

      setState(() {
        _events = events;
        _selectedEvents = _getEventsForDay(_selectedDay);
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  void _addRecurringEvents(
    Map<DateTime, List<Map<String, String>>> events,
    DateTime startDate,
    String frequency,
    String taskTitle,
    String taskDescription,
    String dueTime,
    DateTime? recurrenceEndDate,
    int maxOccurrences,
    String recurrenceEndType,
    int interval, // Pass the interval value received from the server as a parameter
  ) {
    DateTime recurringDate = startDate;
    int occurrencesCount = 0;

    // Calculate the interval (days, weeks, months, years)
    print("Setting frequency: $frequency, interval: $interval");

    switch (frequency) {
      case 'daily':
        // Use the interval directly, e.g., repeat every 2 days
        interval = interval * 1;
        break;
      case 'weekly':
        // Set interval as interval * 7 days, e.g., repeat every 2 weeks
        interval = interval * 7;
        break;
      case 'monthly':
        // Set interval as interval * 30 days, e.g., repeat every 2 months
        interval = interval * 30;
        break;
      case 'yearly':
        // Set interval as interval * 365 days, e.g., repeat every 2 years
        interval = interval * 365;
        break;
    }

    if (recurrenceEndType == 'none') {
      print("No recurrence. Single task.");
      return; // Do not add recurring events
    }

    // Handle the recurrence end condition using a while loop
    if (recurrenceEndType == 'date') {
      // 'date' condition (end date provided)
      while (recurrenceEndDate == null || recurringDate.isBefore(recurrenceEndDate)) {
        if (occurrencesCount == 0) {
          recurringDate = recurringDate.add(Duration(days: 1)); // Skip the first day
        }

        DateTime normalizedRecurringDate = DateTime(recurringDate.year, recurringDate.month, recurringDate.day);

        if (!events.containsKey(normalizedRecurringDate)) {
          events[normalizedRecurringDate] = [];
        }

        events[normalizedRecurringDate]?.add({
          'title': taskTitle,
          'description': taskDescription,
          'dueTime': dueTime,
          'type': 'recurring',
          'recurrence': 'Recurring task',
        });

        print('Recurring event added: $taskTitle $normalizedRecurringDate');

        recurringDate = recurringDate.add(Duration(days: interval)); // Add the interval
        occurrencesCount++; // Increase occurrences count
      }
    }

    if (recurrenceEndType == 'occurrences') {
      print("Repeating based on occurrence count.");
      while (occurrencesCount < maxOccurrences) {
        if (occurrencesCount == 0) {
          recurringDate = recurringDate.add(Duration(days: 1)); // Skip the first day
        }

        DateTime normalizedRecurringDate = DateTime(recurringDate.year, recurringDate.month, recurringDate.day);

        if (!events.containsKey(normalizedRecurringDate)) {
          events[normalizedRecurringDate] = [];
        }

        events[normalizedRecurringDate]?.add({
          'title': taskTitle,
          'description': taskDescription,
          'dueTime': dueTime,
          'type': 'recurring',
          'recurrence': 'Recurring task',
        });

        print('Recurring event added: $taskTitle $normalizedRecurringDate');

        occurrencesCount++; // Increase occurrences count
        recurringDate = recurringDate.add(Duration(days: interval)); // Add the interval
      }
    }

    if (recurrenceEndType == 'never') {
      DateTime farFutureDate = DateTime(2050); // Set to a very far future date

      while (recurringDate.isBefore(farFutureDate)) {
        if (occurrencesCount == 0) {
          recurringDate = recurringDate.add(Duration(days: 1)); // Skip the first day
        }

        DateTime normalizedRecurringDate = DateTime(recurringDate.year, recurringDate.month, recurringDate.day);

        if (!events.containsKey(normalizedRecurringDate)) {
          events[normalizedRecurringDate] = [];
        }

        events[normalizedRecurringDate]?.add({
          'title': taskTitle,
          'description': taskDescription,
          'dueTime': dueTime,
          'type': 'recurring',
          'recurrence': 'Recurring task',
        });

        print('Recurring event added: $taskTitle $normalizedRecurringDate');

        recurringDate = recurringDate.add(Duration(days: interval)); // Add the interval
        occurrencesCount++; // Increase occurrences count
      }

      print("‘never’ recurrence ended");
    }

    print("Recurrence ended.");
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

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
            lastDay: DateTime(2050),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: (day) => _getEventsForDay(day),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        // Display a blue dot for events
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            color: Colors.blue, // Set to blue
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
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
                        subtitle: task['dueTime'] != ""
                            ? Text('${task['description'] ?? 'No Description'} - ${task['dueTime']}')
                            : Text('${task['description'] ?? 'No Description'}'),
                        tileColor: task['type'] == 'recurring' ? Colors.yellow[100] : null, // Mark recurring tasks with a different color
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
