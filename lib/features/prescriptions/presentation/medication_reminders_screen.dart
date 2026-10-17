import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../api/retrofit_Api.dart';
import '../../../main.dart' show flutterLocalNotificationsPlugin;
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../../astra/data/astra_service.dart';
import '../../medicine_reminders/presentation/medicine_reminder_service.dart';
import '../data/paused_reminder_store.dart';
import 'dose_reminder_scheduler.dart';

class _PendingDose {
  final int notificationId;
  final String reminderId;
  final String title;
  final String body;
  final DateTime? scheduledFor;

  const _PendingDose({
    required this.notificationId,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.scheduledFor,
  });
}

/// Matches the Stitch "Medication Reminders" screen
/// (ayureze_medication_reminders/code.html), built from what's actually
/// real: this app's reminders are local notifications only (there's no
/// server-side "today's doses" list - see dose_reminder_scheduler.dart),
/// so this reads flutter_local_notifications' own pending queue
/// (pendingNotificationRequests()) rather than a fabricated schedule.
/// The Taken/Skip/Snooze actions here do the same thing the OS
/// notification's action buttons do (ack to Astra, best-effort log to
/// the server-side reminder, cancel/reschedule the local notification).
class MedicationRemindersScreen extends HookWidget {
  const MedicationRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doses = useState<List<_PendingDose>>([]);
    final pausedMedicines = useState<Map<String, (String, String, int)>>({});
    final loading = useState(true);

    Future<void> load() async {
      loading.value = true;
      try {
        pausedMedicines.value = await PausedReminderStore.getPaused();
        final pending =
            await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        final parsed = <_PendingDose>[];
        for (final p in pending) {
          if (p.payload == null) continue;
          Map<String, dynamic> data;
          try {
            data = jsonDecode(p.payload!) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }
          if (data['screen'] != 'reminder_ack') continue;
          final scheduledForRaw = data['scheduled_for'] as String?;
          parsed.add(_PendingDose(
            notificationId: p.id,
            reminderId: '${data['reminder_id']}',
            title: p.title ?? data['title'] as String? ?? 'Medicine reminder',
            body: p.body ?? data['body'] as String? ?? '',
            scheduledFor: scheduledForRaw != null
                ? DateTime.tryParse(scheduledForRaw)
                : null,
          ));
        }
        parsed.sort((a, b) {
          if (a.scheduledFor == null || b.scheduledFor == null) return 0;
          return a.scheduledFor!.compareTo(b.scheduledFor!);
        });
        doses.value = parsed;
      } catch (e) {
        logger.e('Failed to load pending dose reminders: $e');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> ack(_PendingDose dose, String status) async {
      try {
        await flutterLocalNotificationsPlugin.cancel(dose.notificationId);
        try {
          final dio = await RetroApi().dioData(context);
          await AstraService.withDio(dio)
              .repository
              .ackReminder(dose.reminderId, status);
        } catch (e) {
          logger.e('Failed to ack reminder: $e');
        }
        final serverReminderId = serverReminderIdFor(dose.reminderId);
        if (serverReminderId != null) {
          try {
            final reminderService = MedicineReminderService.create();
            if (status == 'snoozed') {
              await reminderService.snooze(reminderId: serverReminderId);
            } else {
              await reminderService.logAdherence(
                reminderId: serverReminderId,
                taken: status == 'taken',
              );
            }
          } catch (e) {
            logger.e('Failed to sync reminder adherence to server: $e');
          }
        }
        if (status == 'snoozed') {
          await snoozeReminder(dose.reminderId, dose.title, dose.body);
        }
        Fluttertoast.showToast(
            msg: status == 'taken'
                ? 'Marked as taken'
                : status == 'skipped'
                    ? 'Dose skipped'
                    : 'Snoozed for 15 minutes');
        await load();
      } catch (e) {
        logger.e('Failed to update reminder: $e');
        Fluttertoast.showToast(msg: 'Could not update reminder');
      }
    }

    Future<void> pauseMedicine(String medicineKey) async {
      try {
        final pending =
            await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        final count =
            await PausedReminderStore.pauseMedicine(medicineKey, pending);
        Fluttertoast.showToast(
            msg: count > 0
                ? 'Paused $count upcoming reminder${count == 1 ? '' : 's'}'
                : 'Nothing to pause');
        await load();
      } catch (e) {
        logger.e('Failed to pause reminders: $e');
        Fluttertoast.showToast(msg: 'Could not pause reminders');
      }
    }

    Future<void> resumeMedicine(String medicineKey) async {
      try {
        final count = await PausedReminderStore.resumeMedicine(medicineKey);
        Fluttertoast.showToast(
            msg: count > 0
                ? 'Resumed $count reminder${count == 1 ? '' : 's'}'
                : 'Those reminder times have already passed');
        await load();
      } catch (e) {
        logger.e('Failed to resume reminders: $e');
        Fluttertoast.showToast(msg: 'Could not resume reminders');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Medication Reminders'),
          if (loading.value)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sagePrimary),
              ),
            )
          else if (doses.value.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.medication_outlined,
                          size: 56, color: AppColors.slateTextMuted),
                      const SizedBox(height: 14),
                      const Text(
                        'No reminders scheduled',
                        style: TextStyle(color: AppColors.slateTextMuted),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Set reminders from a prescription to see them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.slateTextMuted),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doses.value.length,
                itemBuilder: (context, index) {
                  final dose = doses.value[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.sagePrimarySubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.medication_outlined,
                                  size: 18, color: AppColors.sagePrimary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dose.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  Text(dose.body,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            if (dose.scheduledFor != null)
                              Text(
                                DateFormat('d MMM, h:mm a')
                                    .format(dose.scheduledFor!),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slateTextMuted),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.sagePrimary,
                                  side: const BorderSide(
                                      color: AppColors.sagePrimary),
                                ),
                                onPressed: () => ack(dose, 'taken'),
                                child: const Text('Taken'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => ack(dose, 'skipped'),
                                child: const Text('Skip'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.amberWarning,
                                  side: const BorderSide(
                                      color: AppColors.amberWarning),
                                ),
                                onPressed: () => ack(dose, 'snoozed'),
                                child: const Text('Snooze'),
                              ),
                            ),
                          ],
                        ),
                        if (medicineKeyFor(dose.reminderId) != null) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.pause_circle_outline,
                                  size: 16),
                              label: const Text('Pause remaining doses'),
                              onPressed: () => pauseMedicine(
                                  medicineKeyFor(dose.reminderId)!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          if (pausedMedicines.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Paused', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  for (final entry in pausedMedicines.value.entries)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.pause_circle_outline,
                            color: AppColors.amberWarning),
                        title: Text(entry.value.$1),
                        subtitle: Text(
                            '${entry.value.$3} upcoming dose${entry.value.$3 == 1 ? '' : 's'} paused'),
                        trailing: TextButton(
                          onPressed: () => resumeMedicine(entry.key),
                          child: const Text('Resume'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
