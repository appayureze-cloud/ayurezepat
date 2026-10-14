import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../VideoCall/videoCall.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/appointment.dart';
import 'appointment_service.dart';
import 'care_feedback_screen.dart';
import 'doctor_list_screen.dart';

/// Matches the Stitch "My Appointments" screen
/// (ayureze_my_appointments/code.html): a segmented Upcoming/Past
/// control, each appointment as a card with a status chip (icon +
/// label, never color alone) and contextual actions.
class MyAppointmentsScreen extends HookWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = useState<List<Appointment>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);
    final showPast = useState(false);
    final service = useMemoized(() => AppointmentService());

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        appointments.value = await service.myAppointments();
      } catch (e) {
        logger.e('Failed to load appointments: $e');
        error.value = 'Could not load your appointments';
        Fluttertoast.showToast(msg: 'Could not load your appointments');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> cancel(Appointment appointment) async {
      try {
        await service.cancel(appointment.consultationId);
        Fluttertoast.showToast(msg: 'Appointment cancelled');
        await load();
      } catch (e) {
        logger.e('Cancel failed: $e');
        Fluttertoast.showToast(msg: 'Could not cancel appointment');
      }
    }

    final now = DateTime.now();
    final visible = appointments.value.where((a) {
      final isUpcoming = !a.isCancelled && a.appointmentDate.isAfter(now);
      return showPast.value ? !isUpcoming : isUpcoming;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final booked = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const DoctorListScreen()),
          );
          if (booked == true) await load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
      body: Column(
        children: [
          const Header_v2(title: 'My Appointments'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.creamSurfaceLow,
                borderRadius: AppRadius.roundedPill,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Upcoming',
                      selected: !showPast.value,
                      onTap: () => showPast.value = false,
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Past',
                      selected: showPast.value,
                      onTap: () => showPast.value = true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading.value)
            const Expanded(
              child: Center(
                child:
                    SpinKitFadingCircle(color: AppColors.sagePrimary, size: 36),
              ),
            )
          else if (error.value != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error.value!),
                    const SizedBox(height: 14),
                    ElevatedButton(onPressed: load, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (visible.isEmpty)
            Expanded(
                child: Center(
                    child: Text(
                        showPast.value
                            ? 'No past appointments'
                            : 'No upcoming appointments',
                        style:
                            const TextStyle(color: AppColors.slateTextMuted))))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: visible.length,
                itemBuilder: (context, index) => _AppointmentTile(
                  appointment: visible[index],
                  onCancel: cancel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.creamSurfaceLowest : null,
          borderRadius: AppRadius.roundedPill,
          boxShadow: selected ? AppShadows.subtleCard : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                selected ? AppColors.sagePrimary : AppColors.slateTextSecondary,
          ),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final void Function(Appointment) onCancel;

  const _AppointmentTile({required this.appointment, required this.onCancel});

  (Color, Color, IconData, String) _status() {
    if (appointment.isCancelled) {
      return (
        AppColors.clayAlertContainer,
        AppColors.clayAlert,
        Icons.cancel_outlined,
        'Cancelled'
      );
    }
    if (appointment.isPaid) {
      return (
        AppColors.sagePrimaryContainer,
        AppColors.sagePrimary,
        Icons.check_circle_outline,
        'Confirmed'
      );
    }
    return (
      AppColors.amberWarningContainer,
      AppColors.amberWarning,
      Icons.schedule,
      'Payment pending'
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = !appointment.isCancelled &&
        appointment.appointmentDate.isAfter(DateTime.now());
    final (bgColor, fgColor, statusIcon, statusLabel) = _status();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(appointment.doctorName,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.roundedPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: fgColor),
                    const SizedBox(width: 4),
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: fgColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('d MMM yyyy, h:mm a')
                .format(appointment.appointmentDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (appointment.totalFee != null)
            Text('₹${appointment.totalFee}',
                style: Theme.of(context).textTheme.bodySmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!appointment.isCancelled &&
                  appointment.isPaid &&
                  appointment.consultationType == 'video')
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VideoCall(astraDoctorId: appointment.doctorId),
                    ),
                  ),
                  icon: const Icon(Icons.videocam,
                      color: AppColors.sagePrimary, size: 18),
                  label: const Text('Join call'),
                ),
              if (!appointment.isCancelled &&
                  appointment.isPaid &&
                  appointment.appointmentDate.isBefore(DateTime.now()))
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CareFeedbackScreen(appointment: appointment),
                    ),
                  ),
                  icon: const Icon(Icons.star_outline,
                      color: AppColors.terracottaSecondary, size: 18),
                  label: const Text('Rate'),
                ),
              if (canCancel)
                TextButton(
                  onPressed: () => onCancel(appointment),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.clayAlert)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
