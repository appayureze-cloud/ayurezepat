import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../../case/presentation/case_service.dart';
import '../data/health_record_service.dart';
import '../domain/entities/health_record_entry.dart';

class HealthRecordTimelineScreen extends HookWidget {
  const HealthRecordTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = useState<List<HealthRecordEntry>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final dio = await RetroApi().dioData(context);
        final caseModel = await CaseService.withDio(dio).ensureActiveCase();
        // The real backend (GET /api/companion/case/{id}/health_records)
        // already aggregates encounters, prescriptions and the patient's
        // uploaded documents server-side - no separate client-side merge
        // needed (removed here; it used to duplicate what the backend
        // now returns).
        final timeline =
            await HealthRecordService.create().getTimeline(caseModel.id);
        entries.value = timeline;
      } catch (e) {
        logger.e('Failed to load health record timeline: $e');
        error.value = 'Could not load your health record';
        Fluttertoast.showToast(msg: 'Could not load your health record');
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
          Header_v2(title: 'Health Record'),
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
          else if (entries.value.isEmpty)
            const Expanded(child: Center(child: Text('No health records yet')))
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(4.w),
                children: [
                  for (final entry in entries.value)
                    _TimelineTile(entry: entry),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final HealthRecordEntry entry;

  const _TimelineTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (entry) {
      EncounterEntry e => (
          Icons.medical_services_outlined,
          'Consult with ${e.doctorName}',
          e.specialty ?? '',
        ),
      PrescriptionEntry e => (
          Icons.receipt_long_outlined,
          'Prescription from ${e.doctorName}',
          '',
        ),
      ReportEntry e => (Icons.description_outlined, e.title, ''),
    };

    final currentEntry = entry;
    final reportUrl = currentEntry is ReportEntry && currentEntry.url.isNotEmpty
        ? currentEntry.url
        : null;

    return GestureDetector(
      onTap: reportUrl == null
          ? null
          : () => launchUrl(Uri.parse(reportUrl),
              mode: LaunchMode.externalApplication),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.75.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: Palette.lightGrey),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Row(
          children: [
            Icon(icon, color: Palette.primary, size: 6.w),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.sp)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp, color: Palette.dark_grey)),
                  Text(
                    DateFormat('d MMM yyyy').format(entry.at),
                    style: TextStyle(fontSize: 11.sp, color: Palette.dark_grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
