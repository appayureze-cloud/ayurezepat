import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../v2/utils/logger.dart';
import '../../../v2/utils/notification_id.dart';
import '../../astra/data/astra_gateway_auth.dart';
import '../../medicine_reminders/presentation/medicine_reminder_service.dart';
import '../domain/dose_schedule.dart';
import '../domain/entities/prescription_item.dart';

/// A locally-synthesized reminder id, since these reminders are derived
/// entirely on-device from a prescription's structured items rather than
/// coming from `GET /astra/cases/{id}/plan` (that endpoint - see
/// docs/backend/astra.md - isn't wired into any screen yet). The backend's
/// `POST /astra/reminders/{id}/ack` needs to accept this opaque
/// client-minted id rather than assuming it was minted server-side; see
/// the `plan`/`checkins`/reminders section of docs/backend/astra.md.
String reminderIdFor({
  required int prescriptionId,
  required int itemIndex,
  required int day,
  required int doseIndex,
}) =>
    'presc$prescriptionId-item$itemIndex-day$day-dose$doseIndex';

final _localReminderIdPattern =
    RegExp(r'^presc(\d+)-item(\d+)-day\d+-dose\d+$');

String _serverReminderCacheKey(int prescriptionId, int itemIndex) =>
    '${Preferences.serverReminderIdPrefix}$prescriptionId-item$itemIndex';

/// Looks up the server-side reminder id (see medicine_reminder_service.dart)
/// created for the medicine a local reminder notification belongs to, by
/// parsing the prescription/item out of its locally-synthesized id. Returns
/// null if no server reminder was created for it (e.g. it predates this
/// feature, or creation failed).
String? serverReminderIdFor(String localReminderId) {
  final match = _localReminderIdPattern.firstMatch(localReminderId);
  if (match == null) return null;
  final key = _serverReminderCacheKey(
      int.parse(match.group(1)!), int.parse(match.group(2)!));
  final id = SharedPreferenceHelper.getString(key);
  return (id == null || id.isEmpty) ? null : id;
}

/// Schedules one local notification per dose, per day, for the item's
/// `duration_days`, starting today. Each carries Taken/Skip/Snooze actions;
/// main.dart's notification handler posts the result to
/// `AstraRepository.ackReminder`. Also best-effort registers the medicine
/// with the real server-side reminders API (see
/// medicine_reminder_service.dart) so WhatsApp reminders/adherence
/// tracking work too, once Env.useMockServerReminders is flipped - a
/// failure here never blocks the local notifications, which are the
/// reminder mechanism this app actually depends on today.
Future<void> scheduleDoseReminders({
  required int prescriptionId,
  required int itemIndex,
  required PrescriptionItem item,
}) async {
  final doseTimes = defaultDoseTimesFor(timesPerDayFor(item.frequency));
  final now = DateTime.now();

  unawaited(_createServerReminder(
    prescriptionId: prescriptionId,
    itemIndex: itemIndex,
    item: item,
    doseTimes: doseTimes,
    now: now,
  ));

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

Future<void> _createServerReminder({
  required int prescriptionId,
  required int itemIndex,
  required PrescriptionItem item,
  required List<DoseTime> doseTimes,
  required DateTime now,
}) async {
  try {
    final cacheKey = _serverReminderCacheKey(prescriptionId, itemIndex);
    final existing = SharedPreferenceHelper.getString(cacheKey);
    if (existing != null && existing.isNotEmpty) {
      // Already registered (e.g. the "Set Dose Reminders" button was
      // tapped twice, or the screen was revisited) - creating again would
      // duplicate the server-side reminder and orphan the old one, since
      // there's no cancel/delete call here.
      return;
    }
    final patientId = AstraGatewayAuth().cachedUserId;
    if (patientId == null || patientId.isEmpty) {
      // No Astra session yet (patient hasn't opened Astra chat), so there's
      // no patient id to register this reminder against on the gateway.
      // The local notifications above still work regardless.
      return;
    }
    final endDate = now.add(Duration(days: item.durationDays));
    final id = await MedicineReminderService.create().createReminder(
      patientId: patientId,
      patientName: SharedPreferenceHelper.getString(Preferences.name),
      patientPhone: SharedPreferenceHelper.getString(Preferences.phone),
      medicineName: item.name,
      dosage: item.dose,
      frequency: item.frequency,
      times: doseTimes.map((t) => t.toString()).toList(),
      startDate: _isoDate(now),
      endDate: _isoDate(endDate),
      instructions: item.instructions,
    );
    if (id != null) {
      await SharedPreferenceHelper.setString(
          _serverReminderCacheKey(prescriptionId, itemIndex), id);
    }
  } catch (e) {
    logger.e('Failed to register server-side reminder: $e');
  }
}

String _isoDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

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
