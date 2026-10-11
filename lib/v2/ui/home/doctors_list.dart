import 'package:doctro_patient/v2/ui/widgets/doctor_info_card.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/appointment_service.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';

/// Doctor directory sourced from the real Astra/Supabase `doctors` table
/// (GET /api/v1/appointments/doctors) - the Laravel doctor directory this
/// used to read from is a separate identity space (int ids vs Astra's
/// string doctor_ids) with no confirmed mapping, so this fetches and
/// filters client-side instead of carrying over Laravel's
/// category/distance/rating filter model, which Astra's endpoint doesn't
/// support.
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
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header_v2(title: 'Top Doctors'),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              child: TextField(
                controller: searchController,
                textCapitalization: TextCapitalization.words,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (text) {
                  debouncer.run(() {
                    query.value = text;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Palette.white,
                  constraints: BoxConstraints(
                    maxHeight: 5.5.h,
                    maxWidth: 95.w,
                  ),
                  hintText: "Search Doctor",
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Palette.grey,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_outlined,
                      size: 17.sp,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            if (!loading.value && filtered.isEmpty)
              NoDataWidget(
                onRetry: loadDoctors,
              ),
            for (DoctorSummary doctor in filtered)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: DoctorInfoCard_v2(doctor: doctor),
              ),
          ],
        ),
      ),
    );
  }
}
