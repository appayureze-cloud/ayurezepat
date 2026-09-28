import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../v2/utils/notification_id.dart';

/// When an ignored smart order draft should re-nudge the patient. A pure
/// function so the "24 hours later" rule is unit-testable without a real
/// clock or the notifications plugin.
DateTime nextRepromptTime(DateTime now) => now.add(const Duration(hours: 24));

/// Schedules a local notification reminding the patient about an ignored
/// smart order draft. Tapping it should open the draft screen again -
/// wired the same way as the existing download-complete notification
/// (lib/v2/utils/notification_service.dart): payload carries the draft id,
/// main.dart's NotificationHandler routes on it.
Future<void> scheduleSmartOrderReprompt(String draftId) async {
  final at = tz.TZDateTime.from(nextRepromptTime(DateTime.now()), tz.local);

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'smart_order_reprompt',
      'Order reminders',
      channelDescription: 'Reminders about medicines from a prescription',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    ),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationIdFor(draftId),
    'Still need those medicines?',
    'Your doctor prescribed some medicines you haven\'t ordered yet.',
    at,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: '{"screen":"smart_order_draft","draft_id":"$draftId"}',
  );
}

Future<void> cancelSmartOrderReprompt(String draftId) =>
    flutterLocalNotificationsPlugin.cancel(notificationIdFor(draftId));
