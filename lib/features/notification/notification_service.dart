import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_habit_tracker/main.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<bool?> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final bool? granted =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

    if (granted == true) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        androidScheduleMode: AndroidScheduleMode.exact,
        id,
        title,
        body,
        _nextInstanceOfTime(time),
        const NotificationDetails(android: AndroidNotificationDetails('daily_channel', 'Daily Reminders')),
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    return granted;
  }

  static tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
