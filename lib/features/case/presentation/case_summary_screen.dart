import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../api/retrofit_Api.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../astra/data/astra_service.dart';
import '../../astra/presentation/astra_chat_screen.dart';
import '../../astra/presentation/daily_checkin_reminder_scheduler.dart';
import '../../../v2/utils/logger.dart';
import '../data/case_history_store.dart';
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

/// Matches the Stitch "Case Closure" screen (ayureze_case_closure/code.html):
/// a calm wrap-up card summarizing the case, with the closing action.
///
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
        // Best-effort: records this closed journey into the local
        // Companion Chat History (see CaseHistoryStore) - never blocks
        // the case from actually closing if this fails.
        try {
          await CaseHistoryStore.recordClosed(activeCase.value!);
        } catch (e) {
          logger.e('Failed to record case history: $e');
        }
      } catch (e) {
        error.value = 'Could not close your case. Please try again.';
      } finally {
        resolving.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'My Case'),
          Expanded(
            child: loading.value
                ? const Center(
                    child: SpinKitFadingCircle(
                        color: AppColors.sagePrimary, size: 36),
                  )
                : activeCase.value == null
                    ? Center(
                        child: Text(error.value ?? 'No case found.',
                            style: const TextStyle(color: AppColors.clayAlert)),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.creamSurfaceLowest,
                                border: Border.all(
                                    color:
                                        AppColors.sagePrimary.withOpacity(0.1)),
                                borderRadius: AppRadius.roundedLg,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.sagePrimarySubtle,
                                      borderRadius: AppRadius.roundedPill,
                                    ),
                                    child: Text(
                                      _statusLabel(activeCase.value!.status),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppColors.sagePrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _statusDescription(
                                        activeCase.value!.status),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (error.value != null) ...[
                              const SizedBox(height: 14),
                              Text(error.value!,
                                  style: const TextStyle(
                                      color: AppColors.clayAlert)),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: activeCase.value!.isActive
                                  ? ElevatedButton(
                                      onPressed:
                                          resolving.value ? null : resolve,
                                      child: Text(resolving.value
                                          ? 'Closing...'
                                          : 'Close this case'),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const AstraChatScreen()),
                                      ),
                                      child:
                                          const Text('Start new consultation'),
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
