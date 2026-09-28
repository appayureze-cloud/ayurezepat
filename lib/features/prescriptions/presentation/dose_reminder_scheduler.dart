import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../v2/utils/notification_id.dart';
import '../domain/dose_schedule.dart';
import '../domain/entities/prescription_item.dart';

/// A locally-synthesized reminder id, since these reminders are derived
/// entirely on-device from a prescription's structured items rather than
/// coming from `GET /astra/cases/{id}/plan` (that endpoint - see
/// docs/backend/astra.md - isn't wired into any screen yet). The backend's
/// `POST /astra/reminders/{id}/ack` needs to accept this opaque id rather
/// than assuming it was minted server-side; see docs/backend/reminders.md.
String reminderIdFor({
  required int prescriptionId,
  required int itemIndex,
  required int day,
  required int doseIndex,
}) =>
    'presc$prescriptionId-item$itemIndex-day$day-dose$doseIndex';

/// Schedules one local notification per dose, per day, for the item's
/// `duration_days`, starting today. Each carries Taken/Skip/Snooze actions;
/// main.dart's notification handler posts the result to
/// `AstraRepository.ackReminder`.
Future<void> scheduleDoseReminders({
  required int prescriptionId,
  required int itemIndex,
  required PrescriptionItem item,
}) async {
  final doseTimes = defaultDoseTimesFor(timesPerDayFor(item.frequency));
  final now = DateTime.now();

  for (var day = 0; day < item.durationDays; day++) {
    for (var doseIndex = 0; doseIndex < doseTimes.length; doseIndex++) {
      final doseTime = doseTimes[doseIndex];
      var scheduledFor = DateTime(
        now.year,
        now.month,
        now.day + day,
        doseTime.hour,
        doseTime.minute,
      );
      if (scheduledFor.isBefore(now)) {
        // Only possible for day 0 doses earlier than the current time -
        // push those to tomorrow rather than firing immediately.
        scheduledFor = scheduledFor.add(const Duration(days: 1));
      }

      final reminderId = reminderIdFor(
        prescriptionId: prescriptionId,
        itemIndex: itemIndex,
        day: day,
        doseIndex: doseIndex,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationIdFor(reminderId),
        'Time for ${item.name}',
        '${item.dose} - ${item.timing}',
        tz.TZDateTime.from(scheduledFor, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'dose_reminder',
            'Medicine reminders',
            channelDescription: 'Reminders to take prescribed medicines',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            actions: const [
              AndroidNotificationAction('reminder_taken', 'Taken',
                  showsUserInterface: false, cancelNotification: true),
              AndroidNotificationAction('reminder_skip', 'Skip',
                  showsUserInterface: false, cancelNotification: true),
              AndroidNotificationAction('reminder_snooze', 'Snooze 15m',
                  showsUserInterface: false, cancelNotification: true),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'screen': 'reminder_ack',
          'reminder_id': reminderId,
          'title': 'Time for ${item.name}',
          'body': '${item.dose} - ${item.timing}',
        }),
      );
    }
  }
}

/// Reschedules a single reminder 15 minutes from now, for the "Snooze"
/// action.
Future<void> snoozeReminder(
    String reminderId, String title, String body) async {
  final at = tz.TZDateTime.from(
    DateTime.now().add(const Duration(minutes: 15)),
    tz.local,
  );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationIdFor(reminderId),
    title,
    body,
    at,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'dose_reminder',
        'Medicine reminders',
        channelDescription: 'Reminders to take prescribed medicines',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: jsonEncode({
      'screen': 'reminder_ack',
      'reminder_id': reminderId,
    }),
  );
}
