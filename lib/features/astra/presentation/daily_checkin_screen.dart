import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/nav_constants.dart';
import '../../case/presentation/case_service.dart';
import '../data/astra_service.dart';
import 'astra_chat_screen.dart';
import 'daily_checkin_notifier.dart';

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
      body: Column(
        children: [
          const Header_v2(title: 'Daily Check-in'),
          Expanded(
            child: notifier.value == null
                ? Center(
                    child: bootstrapError.value != null
                        ? Text(
                            bootstrapError.value!,
                            style: TextStyle(color: Palette.red),
                          )
                        : SpinKitFadingCircle(
                            color: Palette.primary, size: 6.h),
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
        padding: EdgeInsets.all(4.w),
        child: result.escalate
            ? _EscalationCard(onDone: () => Navigator.pop(context))
            : _AllGoodCard(onDone: () => Navigator.pop(context)),
      );
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          SizedBox(height: 1.h),
          Text(
            '1 = same as usual, 5 = much worse',
            style: TextStyle(fontSize: 12.sp, color: Palette.dark_grey),
          ),
          SizedBox(height: 2.h),
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
            SizedBox(height: 2.h),
            Text(notifier.error!, style: TextStyle(color: Palette.red)),
          ],
          SizedBox(height: 3.h),
          ButtonV2(
            label: notifier.status == DailyCheckinStatus.submitting
                ? 'Submitting...'
                : 'Submit',
            onPressed: notifier.status == DailyCheckinStatus.submitting
                ? null
                : notifier.submit,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 5.w,
        backgroundColor: selected ? Palette.primary : Palette.primary_bg,
        child: Text(
          '$score',
          style: TextStyle(
            color: selected ? Palette.white : Palette.black,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        Icon(Icons.check_circle, color: Palette.primary, size: 10.w),
        SizedBox(height: 1.h),
        Text(
          'Thanks for checking in. Keep following your treatment plan.',
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 3.h),
        ButtonV2(label: 'Done', onPressed: onDone),
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
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Palette.red_bg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: Palette.red, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Palette.red, size: 5.w),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  "It's worth getting this checked",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: Palette.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Your symptoms sound worse than usual. Talk to Astra or book a '
            'doctor so they can take a look.',
            style: TextStyle(fontSize: 13.sp, color: Palette.black),
          ),
          SizedBox(height: 2.h),
          ButtonV2(
            label: 'Chat with Astra',
            buttonColor: Palette.red,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AstraChatScreen()),
              );
            },
          ),
          SizedBox(height: 1.h),
          ButtonV2(
            label: 'Book a Doctor',
            buttonColor: Palette.white,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'Home',
                  arguments: [doctorsTabIndex]);
            },
          ),
        ],
      ),
    );
  }
}
