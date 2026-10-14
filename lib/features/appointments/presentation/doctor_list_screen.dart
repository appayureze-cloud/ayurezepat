import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/doctor_info_card.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/doctor_summary.dart';
import 'appointment_service.dart';

/// Picker shown from My Appointments' "Book" FAB - reuses the same
/// DoctorInfoCard_v2 the Doctor Discovery tab uses, so the two doctor
/// lists in the app look identical.
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
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Book a Doctor'),
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
          else if (doctors.value.isEmpty)
            const Expanded(child: Center(child: Text('No doctors available')))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.value.length,
                itemBuilder: (context, index) => DoctorInfoCard_v2(
                  doctor: doctors.value[index],
                  onBookingResult: (booked) {
                    if (booked) Navigator.pop(context, true);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
