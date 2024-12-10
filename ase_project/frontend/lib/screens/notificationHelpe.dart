import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin and timezone data
  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize timezone data

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Convert DateTime to TZDateTime
  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local; // Get the local timezone
    return tz.TZDateTime.from(dateTime, location);
  }

  // Schedule a notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzDate = _convertToTZDateTime(scheduledDate);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder_channel', // Channel ID
      'Task Reminders', // Channel name
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDate, // Use TZDateTime here
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
