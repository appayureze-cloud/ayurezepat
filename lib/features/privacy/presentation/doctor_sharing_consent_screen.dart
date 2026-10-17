import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../appointments/domain/entities/appointment.dart';
import '../../appointments/presentation/appointment_service.dart';
import '../data/doctor_sharing_consent_store.dart';

/// Per-doctor data-sharing preference, scoped to doctors the patient has
/// actually booked with (via GET /appointments/my) - not a fabricated
/// doctor list. See DoctorSharingConsent's doc comment: this records
/// intent only, since no backend endpoint reads or enforces it yet.
class DoctorSharingConsentScreen extends HookWidget {
  const DoctorSharingConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final doctors = useState<List<Appointment>>([]);
    final consents = useState<Map<String, bool>>({});

    Future<void> load() async {
      loading.value = true;
      try {
        final appointments = await AppointmentService().myAppointments();
        final byDoctor = <String, Appointment>{};
        for (final a in appointments) {
          byDoctor[a.doctorId] = a;
        }
        doctors.value = byDoctor.values.toList();

        final saved = await DoctorSharingConsentStore.getAll();
        final map = <String, bool>{
          for (final c in saved) c.doctorId: c.shareFullRecord,
        };
        consents.value = map;
      } catch (_) {
        doctors.value = [];
      }
      loading.value = false;
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Doctor data sharing'),
          Container(
            width: double.infinity,
            color: AppColors.sagePrimarySubtle,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'This records your preference only. There is no live '
              'mechanism yet that enforces it on the backend - use this to '
              'tell us what you want, and follow up with support for '
              'anything urgent.',
              style:
                  TextStyle(fontSize: 12, color: AppColors.slateTextSecondary),
            ),
          ),
          Expanded(
            child: loading.value
                ? const Center(child: CircularProgressIndicator())
                : doctors.value.isEmpty
                    ? const Center(
                        child: Text(
                          'You haven\'t consulted a doctor yet.',
                          style: TextStyle(color: AppColors.slateTextMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: doctors.value.length,
                        itemBuilder: (context, index) {
                          final appt = doctors.value[index];
                          final shareFull =
                              consents.value[appt.doctorId] ?? true;
                          return SwitchListTile(
                            title: Text(appt.doctorName),
                            subtitle: const Text(
                                'Share my full health record with this doctor'),
                            value: shareFull,
                            onChanged: (value) async {
                              await DoctorSharingConsentStore.setFor(
                                  appt.doctorId, appt.doctorName, value);
                              consents.value = {
                                ...consents.value,
                                appt.doctorId: value,
                              };
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
