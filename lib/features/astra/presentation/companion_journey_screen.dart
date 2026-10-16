import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../api/retrofit_Api.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../case/domain/entities/case.dart';
import '../../case/presentation/case_service.dart';
import '../../case/presentation/companion_chat_history_screen.dart';
import 'astra_chat_screen.dart';
import 'astra_fill_intake_screen.dart';

const _stages = [
  (CaseStatus.open, 'Symptom check-in', Icons.chat_bubble_outline),
  (CaseStatus.consulting, 'Guidance', Icons.psychology_outlined),
  (CaseStatus.treating, 'Treatment plan', Icons.medication_outlined),
  (CaseStatus.followingUp, 'Follow-up', Icons.favorite_outline),
  (CaseStatus.resolved, 'Resolved', Icons.check_circle_outline),
];

int _stageIndex(CaseStatus status) {
  final i = _stages.indexWhere((s) => s.$1 == status);
  if (i >= 0) return i;
  // 'consulting' and 'closed' aren't real Astra states (see Case's doc
  // comment) - treat closed as the end of the resolved stage.
  return status == CaseStatus.closed ? _stages.length - 1 : 0;
}

String _statusNote(CaseStatus status) => switch (status) {
      CaseStatus.open => 'Tell Astra what you\'re experiencing to get started.',
      CaseStatus.consulting =>
        'Astra is working through your symptoms with you.',
      CaseStatus.treating => 'You have an active treatment plan in progress.',
      CaseStatus.followingUp => 'Keep an eye on your daily check-ins.',
      CaseStatus.resolved => 'This journey is resolved.',
      CaseStatus.closed => 'This journey is closed.',
    };

/// Matches the Stitch "Companion Journey Dashboard"
/// (ayureze_companion_journey_dashboard/code.html): a progress
/// visualization of the patient's care journey. Built from the real
/// Case status (the only journey-stage data this backend actually
/// exposes) rather than a richer multi-stage model the backend doesn't
/// have - see docs/stitch-ui-master-prompt.md's Companion Mode batch.
class CompanionJourneyScreen extends HookWidget {
  const CompanionJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final activeCase = useState<Case?>(null);

    useEffect(() {
      Future(() async {
        try {
          final dio = await RetroApi().dioData(context);
          activeCase.value = await CaseService.withDio(dio).ensureActiveCase();
        } catch (_) {
          // Degrades to the "start a conversation" empty state below.
        }
        loading.value = false;
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(
            title: 'Your Journey',
            actions: [
              IconButton(
                tooltip: 'Health intake',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AstraFillIntakeScreen()),
                ),
                icon: const Icon(Icons.assignment_outlined,
                    color: AppColors.sagePrimary),
              ),
              IconButton(
                tooltip: 'Companion history',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CompanionChatHistoryScreen()),
                ),
                icon: const Icon(Icons.history, color: AppColors.sagePrimary),
              ),
            ],
          ),
          Expanded(
            child: loading.value
                ? const Center(
                    child: SpinKitFadingCircle(
                        color: AppColors.sagePrimary, size: 36),
                  )
                : activeCase.value == null
                    ? _EmptyJourney()
                    : _JourneyBody(activeCase: activeCase.value!),
          ),
        ],
      ),
    );
  }
}

class _JourneyBody extends StatelessWidget {
  final Case activeCase;

  const _JourneyBody({required this.activeCase});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stageIndex(activeCase.status);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (var i = 0; i < _stages.length; i++)
          _StageTile(
            label: _stages[i].$2,
            icon: _stages[i].$3,
            isDone: i < currentIndex,
            isCurrent: i == currentIndex,
            isLast: i == _stages.length - 1,
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.sagePrimarySubtle,
            borderRadius: AppRadius.roundedMd,
          ),
          child: Text(_statusNote(activeCase.status),
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AstraChatScreen()),
            ),
            child: const Text('Continue conversation'),
          ),
        ),
      ],
    );
  }
}

class _StageTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _StageTile({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final active = isDone || isCurrent;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.sagePrimary
                      : AppColors.creamSurfaceLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 18,
                    color: active
                        ? AppColors.sageOnPrimary
                        : AppColors.slateTextMuted),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        isDone ? AppColors.sagePrimary : AppColors.slateBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 20),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? AppColors.slateTextPrimary
                    : AppColors.slateTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyJourney extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_outlined,
                size: 56, color: AppColors.slateTextMuted),
            const SizedBox(height: 14),
            const Text('No active journey yet',
                style: TextStyle(color: AppColors.slateTextMuted)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AstraChatScreen()),
              ),
              child: const Text('Talk to Astra'),
            ),
          ],
        ),
      ),
    );
  }
}
