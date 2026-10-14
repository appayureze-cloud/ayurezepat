import 'package:doctro_patient/v2/ui/widgets/doctor_info_card.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/appointment_service.dart';
import '../../../theme.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';

/// Matches the Stitch "Doctor Discovery" screen
/// (ayureze_doctor_discovery/code.html): search bar + vertical list of
/// doctor cards. Doctor directory sourced from the real Astra/Supabase
/// `doctors` table (GET /api/v1/appointments/doctors) - the Laravel
/// doctor directory this used to read from is a separate identity space
/// (int ids vs Astra's string doctor_ids) with no confirmed mapping, so
/// this fetches and filters client-side instead of carrying over
/// Laravel's category/distance/rating filter model, which Astra's
/// endpoint doesn't support.
class DoctorsList extends HookWidget {
  final int? category;
  final String? search;
  const DoctorsList({this.category, this.search, super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController(text: search);
    final allDoctors = useState<List<DoctorSummary>>([]);
    final loading = useState(false);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 400));
    final query = useState(search ?? '');

    Future<void> loadDoctors() async {
      loading.value = true;
      try {
        allDoctors.value = await AppointmentService().listDoctors();
      } catch (e) {
        logger.e('Error while fetching doctors from Astra: $e');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      loadDoctors();
      return null;
    }, []);

    final filtered = query.value.trim().isEmpty
        ? allDoctors.value
        : allDoctors.value.where((d) {
            final q = query.value.trim().toLowerCase();
            return d.name.toLowerCase().contains(q) ||
                (d.specialization ?? '').toLowerCase().contains(q);
          }).toList();

    return ModalProgressHUD(
      inAsyncCall: loading.value,
      opacity: 0.5,
      progressIndicator: const SpinKitFadingCircle(
        color: AppColors.sagePrimary,
        size: 36,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header_v2(title: 'Doctor Discovery'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                textCapitalization: TextCapitalization.words,
                onChanged: (text) {
                  debouncer.run(() {
                    query.value = text;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search doctors, specializations...',
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.slateTextMuted),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!loading.value && filtered.isEmpty)
              NoDataWidget(
                onRetry: loadDoctors,
              ),
            for (DoctorSummary doctor in filtered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DoctorInfoCard_v2(doctor: doctor),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
