import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../api/retrofit_Api.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/nav_constants.dart';
import '../../case/presentation/case_service.dart';
import '../data/astra_service.dart';
import 'astra_chat_screen.dart';
import 'daily_checkin_notifier.dart';

/// Matches the Stitch "Daily Check-in" screen
/// (ayureze_daily_check_in/code.html): a calm 1-5 intensity-circle
/// selector and a non-alarming amber (not red) escalation banner.
///
/// Daily follow-up: asks how the patient is feeling on a 1-5 scale and
/// posts it to `POST /astra/cases/{id}/checkins`. A score the backend
/// flags with `escalate: true` offers a path to Astra chat or rebooking a
/// doctor - this never diagnoses or prescribes on its own, it only routes.
class DailyCheckinScreen extends HookWidget {
  const DailyCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = useState<DailyCheckinNotifier?>(null);
    final bootstrapError = useState<String?>(null);

    useEffect(() {
      Future(() async {
        try {
          final dio = await RetroApi().dioData(context);
          final activeCase = await CaseService.withDio(dio).ensureActiveCase();
          final repository = AstraService.withDio(dio).repository;
          notifier.value = DailyCheckinNotifier(repository, activeCase.id);
        } catch (e) {
          bootstrapError.value =
              'Could not start your check-in. Please try again.';
        }
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Daily Check-in'),
          Expanded(
            child: notifier.value == null
                ? Center(
                    child: bootstrapError.value != null
                        ? Text(
                            bootstrapError.value!,
                            style: const TextStyle(color: AppColors.clayAlert),
                          )
                        : const SpinKitFadingCircle(
                            color: AppColors.sagePrimary, size: 36),
                  )
                : _DailyCheckinBody(notifier: notifier.value!),
          ),
        ],
      ),
    );
  }
}

class _DailyCheckinBody extends HookWidget {
  final DailyCheckinNotifier notifier;

  const _DailyCheckinBody({required this.notifier});

  @override
  Widget build(BuildContext context) {
    useListenable(notifier);

    if (notifier.status == DailyCheckinStatus.done) {
      final result = notifier.result!;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: result.escalate
            ? _EscalationCard(onDone: () => Navigator.pop(context))
            : _AllGoodCard(onDone: () => Navigator.pop(context)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            '1 = same as usual, 5 = much worse',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var score = 1; score <= 5; score++)
                _ScoreButton(
                  score: score,
                  selected: notifier.symptomScore == score,
                  onTap: () => notifier.setScore(score),
                ),
            ],
          ),
          if (notifier.error != null) ...[
            const SizedBox(height: 14),
            Text(notifier.error!,
                style: const TextStyle(color: AppColors.clayAlert)),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: notifier.status == DailyCheckinStatus.submitting
                  ? null
                  : notifier.submit,
              child: Text(notifier.status == DailyCheckinStatus.submitting
                  ? 'Submitting...'
                  : 'Submit check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final int score;
  final bool selected;
  final VoidCallback onTap;

  const _ScoreButton(
      {required this.score, required this.selected, required this.onTap});

  static const _faces = [
    Icons.sentiment_very_satisfied_outlined,
    Icons.sentiment_satisfied_outlined,
    Icons.sentiment_neutral_outlined,
    Icons.sentiment_dissatisfied_outlined,
    Icons.sentiment_very_dissatisfied_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                selected ? AppColors.sagePrimary : AppColors.sagePrimarySubtle,
            child: Icon(
              _faces[score - 1],
              color: selected ? AppColors.sageOnPrimary : AppColors.sagePrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text('$score',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.sagePrimary
                      : AppColors.slateTextMuted)),
        ],
      ),
    );
  }
}

class _AllGoodCard extends StatelessWidget {
  final VoidCallback onDone;

  const _AllGoodCard({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.sagePrimary, size: 48),
        const SizedBox(height: 12),
        Text(
          'Thanks for checking in. Keep following your treatment plan.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onDone, child: const Text('Done')),
        ),
      ],
    );
  }
}

class _EscalationCard extends StatelessWidget {
  final VoidCallback onDone;

  const _EscalationCard({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberWarningContainer,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.amberWarning.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.amberWarning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "It's worth getting this checked",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.amberWarning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your symptoms sound worse than usual. Talk to Astra or book a '
            'doctor so they can take a look.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amberWarning,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AstraChatScreen()),
                );
              },
              child: const Text('Chat with Astra'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'Home',
                    arguments: [doctorsTabIndex]);
              },
              child: const Text('Book a doctor'),
            ),
          ),
        ],
      ),
    );
  }
}
