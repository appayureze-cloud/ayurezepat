import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../v2/utils/notification_id.dart';
import '../presentation/dose_reminder_scheduler.dart' show medicineKeyFor;

class _PausedDose {
  final String reminderId;
  final String title;
  final String body;
  final String scheduledFor; // ISO8601

  const _PausedDose({
    required this.reminderId,
    required this.title,
    required this.body,
    required this.scheduledFor,
  });

  Map<String, dynamic> toJson() => {
        'reminder_id': reminderId,
        'title': title,
        'body': body,
        'scheduled_for': scheduledFor,
      };

  factory _PausedDose.fromJson(Map<String, dynamic> json) => _PausedDose(
        reminderId: json['reminder_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        scheduledFor: json['scheduled_for'] as String,
      );
}

/// Lets a patient pause (and later resume) all of one medicine's remaining
/// dose reminders, rather than only Taken/Skip/Snooze-ing one dose at a
/// time. There's no backend reminder-pause endpoint, so this cancels the
/// local notifications and keeps their data here until resumed.
class PausedReminderStore {
  PausedReminderStore._();

  static const _keyPrefix = 'paused_reminders_';

  static String _storageKey(String medicineKey) => '$_keyPrefix$medicineKey';

  /// Pauses every pending dose whose reminder id belongs to [medicineKey],
  /// given the full list of currently pending notifications (so this
  /// doesn't need its own separate bookkeeping of what's scheduled).
  static Future<int> pauseMedicine(
    String medicineKey,
    List<PendingNotificationRequest> pending,
  ) async {
    final toPause = <_PausedDose>[];
    for (final p in pending) {
      if (p.payload == null) continue;
      Map<String, dynamic> data;
      try {
        data = jsonDecode(p.payload!) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final reminderId = data['reminder_id'] as String?;
      if (reminderId == null || medicineKeyFor(reminderId) != medicineKey) {
        continue;
      }
      final scheduledFor = data['scheduled_for'] as String?;
      if (scheduledFor == null) continue;
      toPause.add(_PausedDose(
        reminderId: reminderId,
        title: p.title ?? data['title'] as String? ?? 'Medicine reminder',
        body: p.body ?? data['body'] as String? ?? '',
        scheduledFor: scheduledFor,
      ));
      await flutterLocalNotificationsPlugin.cancel(p.id);
    }
    if (toPause.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey(medicineKey),
      toPause.map((d) => jsonEncode(d.toJson())).toList(),
    );
    return toPause.length;
  }

  /// Reschedules every paused dose for [medicineKey] whose original time is
  /// still in the future, and drops the ones that already passed while
  /// paused rather than firing them all at once on resume.
  static Future<int> resumeMedicine(String medicineKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey(medicineKey)) ?? [];
    var resumed = 0;
    final now = DateTime.now();
    for (final item in raw) {
      _PausedDose dose;
      try {
        dose = _PausedDose.fromJson(jsonDecode(item));
      } catch (_) {
        continue;
      }
      final scheduledFor = DateTime.tryParse(dose.scheduledFor);
      if (scheduledFor == null || scheduledFor.isBefore(now)) continue;
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationIdFor(dose.reminderId),
        dose.title,
        dose.body,
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
          'reminder_id': dose.reminderId,
          'title': dose.title,
          'body': dose.body,
          'scheduled_for': dose.scheduledFor,
        }),
      );
      resumed++;
    }
    await prefs.remove(_storageKey(medicineKey));
    return resumed;
  }

  /// All medicine keys with at least one paused dose, with a representative
  /// title/body and the count of paused doses, for the paused-medicines
  /// section of MedicationRemindersScreen.
  static Future<Map<String, (String, String, int)>> getPaused() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, (String, String, int)>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;
      final medicineKey = key.substring(_keyPrefix.length);
      final raw = prefs.getStringList(key) ?? [];
      if (raw.isEmpty) continue;
      try {
        final first = _PausedDose.fromJson(jsonDecode(raw.first));
        result[medicineKey] = (first.title, first.body, raw.length);
      } catch (_) {
        // Skip malformed entries.
      }
    }
    return result;
  }
}
