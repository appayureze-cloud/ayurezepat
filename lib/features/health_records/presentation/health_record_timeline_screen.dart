import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/retrofit_Api.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../../case/presentation/case_service.dart';
import '../data/health_record_service.dart';
import '../domain/entities/health_record_entry.dart';

/// Matches the Stitch "Health Record Timeline" screen
/// (ayureze_health_record_timeline/code.html): a real vertical timeline
/// (dot + connecting line) with a compact card and date per event.
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
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Health Record'),
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
          else if (entries.value.isEmpty)
            const Expanded(
                child: Center(
                    child: Text('No health records yet',
                        style: TextStyle(color: AppColors.slateTextMuted))))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                itemCount: entries.value.length,
                itemBuilder: (context, i) => _TimelineTile(
                  entry: entries.value[i],
                  isLast: i == entries.value.length - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final HealthRecordEntry entry;
  final bool isLast;

  const _TimelineTile({required this.entry, required this.isLast});

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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.sagePrimaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.sagePrimary),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.slateBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: reportUrl == null
                    ? null
                    : () => launchUrl(Uri.parse(reportUrl),
                        mode: LaunchMode.externalApplication),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurfaceLowest,
                    border: Border.all(color: AppColors.slateBorder),
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(entry.at),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.slateTextMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
