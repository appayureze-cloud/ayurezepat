import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../astra/data/astra_service.dart';
import '../../astra/presentation/astra_chat_screen.dart';
import '../../astra/presentation/daily_checkin_reminder_scheduler.dart';
import '../../../v2/utils/logger.dart';
import 'case_service.dart';
import '../domain/entities/case.dart';

String _statusLabel(CaseStatus status) => switch (status) {
      CaseStatus.open => 'Open',
      CaseStatus.consulting => 'In consultation',
      CaseStatus.treating => 'Treatment in progress',
      CaseStatus.followingUp => 'Following up',
      CaseStatus.resolved => 'Resolved',
      CaseStatus.closed => 'Closed',
    };

String _statusDescription(CaseStatus status) => switch (status) {
      CaseStatus.open =>
        'Your case has just started. Chat with Astra to get going.',
      CaseStatus.consulting =>
        'You\'re currently consulting with a doctor about this case.',
      CaseStatus.treating =>
        'You have an active treatment plan - medicines and/or therapy.',
      CaseStatus.followingUp =>
        'Your treatment is wrapping up. Keep an eye on your daily check-ins.',
      CaseStatus.resolved =>
        'This case is resolved. You can start a new consultation anytime.',
      CaseStatus.closed => 'This case is closed.',
    };

/// Shows the patient's current case status and, while it's still active,
/// lets them mark it resolved (`POST /astra/cases/{id}/resolve` - see
/// docs/backend/astra.md). This is the patient confirming they're done,
/// not a diagnosis or medical sign-off - Astra/doctors decide treatment,
/// this screen only closes the administrative record.
class CaseSummaryScreen extends HookWidget {
  const CaseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final resolving = useState(false);
    final activeCase = useState<Case?>(null);
    final error = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final dio = await RetroApi().dioData(context);
        activeCase.value = await CaseService.withDio(dio).ensureActiveCase();
      } catch (e) {
        error.value = 'Could not load your case status.';
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> resolve() async {
      final current = activeCase.value;
      if (current == null || resolving.value) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Close this case?'),
          content: const Text(
              'This marks your current case as resolved. You can always '
              'start a new consultation with Astra afterwards.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Close case'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      resolving.value = true;
      error.value = null;
      try {
        final dio = await RetroApi().dioData(context);
        await AstraService.withDio(dio).repository.resolveCase(current.id);
        // Best-effort: a case that's done doesn't need daily nudges anymore,
        // but a failure here shouldn't block the case actually closing.
        try {
          await cancelDailyCheckinReminder();
        } catch (e) {
          logger.e('Failed to cancel daily check-in reminder: $e');
        }
        // Re-read from CaseService rather than assuming resolved locally -
        // CaseRepository is the source of truth for status, and Astra's
        // resolveCase and Case's own repository are gated by independent
        // Env flags (useMockAstra / useMockCases), so they can point at
        // different backends. Re-fetching surfaces that mismatch instead
        // of masking it with an optimistic local update.
        activeCase.value = await CaseService.withDio(dio).getCase(current.id);
      } catch (e) {
        error.value = 'Could not close your case. Please try again.';
      } finally {
        resolving.value = false;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          const Header_v2(title: 'My Case'),
          Expanded(
            child: loading.value
                ? Center(
                    child:
                        SpinKitFadingCircle(color: Palette.primary, size: 6.h),
                  )
                : activeCase.value == null
                    ? Center(
                        child: Text(error.value ?? 'No case found.',
                            style: TextStyle(color: Palette.red)),
                      )
                    : Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLabel(activeCase.value!.status),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  color: Palette.primary),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _statusDescription(activeCase.value!.status),
                              style: TextStyle(
                                  fontSize: 13.sp, color: Palette.dark_grey1),
                            ),
                            if (error.value != null) ...[
                              SizedBox(height: 2.h),
                              Text(error.value!,
                                  style: TextStyle(color: Palette.red)),
                            ],
                            SizedBox(height: 3.h),
                            if (activeCase.value!.isActive)
                              ButtonV2(
                                label: resolving.value
                                    ? 'Closing...'
                                    : 'Close This Case',
                                onPressed: resolving.value ? null : resolve,
                              )
                            else
                              ButtonV2(
                                label: 'Start New Consultation',
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AstraChatScreen()),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
