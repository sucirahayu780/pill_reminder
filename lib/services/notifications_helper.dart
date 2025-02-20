import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> InitializeNotifications() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);


    const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'reminder_channel', 
    "Reminders", 
    description: "Channel for Reminder Notifications",
    importance: Importance.high,
    playSound: true,
    );

    await _notificationsPlugin.
    resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  }
    static Future<void> ScheduleNotification(
    int id, String title, String category, DateTime ScheduleTime) async {
    const AndroidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
     );

    var androidDetails;
    final notificationDetails = NotificationDetails(android: androidDetails);
    if (ScheduleTime.isBefore(DateTime.now())) {
 // do nothing   
    } else {
     await _notificationsPlugin.zonedSchedule(
      id, 
      title, 
      category, 
      tz.TZDateTime.from(ScheduleTime, tz.local), 
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
        UILocalNotificationDateInterpretation.absoluteTime,
        
    );
    }
  }


  static Future<void> CancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
