import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/doctor_summary.dart';
import 'appointment_service.dart';
import 'doctor_booking_screen.dart';

class DoctorListScreen extends HookWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = useState<List<DoctorSummary>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);
    final service = useMemoized(() => AppointmentService());

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        doctors.value = await service.listDoctors();
      } catch (e) {
        logger.e('Failed to load doctors: $e');
        error.value = 'Could not load doctors';
        Fluttertoast.showToast(msg: 'Could not load doctors');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    return Scaffold(
      body: Column(
        children: [
          Header_v2(title: 'Book a Doctor'),
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
          else if (doctors.value.isEmpty)
            const Expanded(child: Center(child: Text('No doctors available')))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: doctors.value.length,
                itemBuilder: (context, index) =>
                    _DoctorTile(doctor: doctors.value[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final DoctorSummary doctor;

  const _DoctorTile({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final booked = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorBookingScreen(doctor: doctor),
          ),
        );
        if (booked == true && context.mounted) Navigator.pop(context, true);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.75.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.lightGrey),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 6.w,
              backgroundColor: Palette.lightGrey,
              backgroundImage:
                  (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                      ? NetworkImage(doctor.photoUrl!)
                      : null,
              child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty)
                  ? Icon(Icons.person, color: Palette.dark_grey, size: 6.w)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(doctor.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13.sp)),
                      ),
                      if (doctor.isVerified)
                        Icon(Icons.verified, color: Palette.primary, size: 4.w),
                    ],
                  ),
                  if ((doctor.specialization ?? '').isNotEmpty)
                    Text(doctor.specialization!,
                        style: TextStyle(
                            fontSize: 11.sp, color: Palette.dark_grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Palette.dark_grey),
          ],
        ),
      ),
    );
  }
}
