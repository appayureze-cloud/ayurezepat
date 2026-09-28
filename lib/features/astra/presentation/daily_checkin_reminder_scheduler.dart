import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../v2/utils/notification_id.dart';

const _dailyCheckinReminderKey = 'daily_checkin';

/// A once-daily local notification nudging the patient to open the daily
/// check-in screen. Scheduled with `matchDateTimeComponents: time` so
/// flutter_local_notifications repeats it every day at the same clock time
/// instead of firing once - rescheduling (e.g. on every app start) is a
/// no-op since it reuses the same notification id.
Future<void> scheduleDailyCheckinReminder() async {
  final now = DateTime.now();
  var firstFireAt = DateTime(now.year, now.month, now.day, 20);
  if (firstFireAt.isBefore(now)) {
    firstFireAt = firstFireAt.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationIdFor(_dailyCheckinReminderKey),
    'How are you feeling today?',
    'Take a moment for your daily check-in with Astra.',
    tz.TZDateTime.from(firstFireAt, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_checkin',
        'Daily check-in',
        channelDescription: 'A daily reminder to log how you\'re feeling',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: jsonEncode({'screen': 'daily_checkin'}),
  );
}

Future<void> cancelDailyCheckinReminder() => flutterLocalNotificationsPlugin
    .cancel(notificationIdFor(_dailyCheckinReminderKey));
