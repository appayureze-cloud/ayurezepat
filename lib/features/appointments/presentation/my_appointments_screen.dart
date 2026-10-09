import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../VideoCall/videoCall.dart';
import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/appointment.dart';
import 'appointment_service.dart';
import 'doctor_list_screen.dart';

class MyAppointmentsScreen extends HookWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = useState<List<Appointment>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);
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

    return Scaffold(
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
        backgroundColor: Palette.primary,
      ),
      body: Column(
        children: [
          Header_v2(title: 'My Appointments'),
          if (loading.value)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(color: Palette.primary, size: 6.h),
              ),
            )
          else if (error.value != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error.value!),
                    SizedBox(height: 2.h),
                    ButtonV2(label: 'Retry', width: 40.w, onPressed: load),
                  ],
                ),
              ),
            )
          else if (appointments.value.isEmpty)
            const Expanded(child: Center(child: Text('No appointments yet')))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: appointments.value.length,
                itemBuilder: (context, index) => _AppointmentTile(
                  appointment: appointments.value[index],
                  onCancel: cancel,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final void Function(Appointment) onCancel;

  const _AppointmentTile({required this.appointment, required this.onCancel});

  Color _statusColor() {
    if (appointment.isCancelled) return Colors.red;
    if (appointment.isPaid) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final canCancel = !appointment.isCancelled &&
        appointment.appointmentDate.isAfter(DateTime.now());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.75.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.lightGrey),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(appointment.doctorName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(
                  appointment.isCancelled
                      ? 'Cancelled'
                      : (appointment.isPaid ? 'Confirmed' : 'Payment pending'),
                  style: TextStyle(fontSize: 10.sp, color: _statusColor()),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            DateFormat('d MMM yyyy, h:mm a').format(appointment.appointmentDate),
            style: TextStyle(fontSize: 11.sp, color: Palette.dark_grey),
          ),
          if (appointment.totalFee != null)
            Text('₹${appointment.totalFee}',
                style: TextStyle(fontSize: 11.sp, color: Palette.dark_grey)),
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
                      builder: (_) => VideoCall(astraDoctorId: appointment.doctorId),
                    ),
                  ),
                  icon: const Icon(Icons.videocam, color: Colors.green),
                  label: const Text('Join call', style: TextStyle(color: Colors.green)),
                ),
              if (canCancel)
                TextButton(
                  onPressed: () => onCancel(appointment),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
