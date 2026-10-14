import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../domain/entities/appointment.dart';

/// Matches the Stitch "Feedback & Rating" screen
/// (ayureze_feedback_rating/code.html). No backend endpoint exists yet
/// for submitting consultation feedback (not in the published Astra
/// OpenAPI spec), so this is UI-only for now: it shows a thank-you state
/// locally rather than silently pretending to submit somewhere real.
class CareFeedbackScreen extends HookWidget {
  final Appointment appointment;

  const CareFeedbackScreen({required this.appointment, super.key});

  @override
  Widget build(BuildContext context) {
    final rating = useState(0);
    final comment = useTextEditingController();
    final submitted = useState(false);

    const ratingLabels = {
      1: '1 star — Needs improvement',
      2: '2 stars — Below expectations',
      3: '3 stars — Satisfactory',
      4: '4 stars — Great care',
      5: '5 stars — Exceptional care & clarity',
    };

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Care Feedback'),
          Expanded(
            child: submitted.value
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.sagePrimary, size: 56),
                        const SizedBox(height: 16),
                        Text('Thank you for your feedback',
                            style: Theme.of(context).textTheme.headlineLarge),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.creamSurfaceLowest,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(
                              color: AppColors.sagePrimary.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.sagePrimaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  color: AppColors.sagePrimary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(appointment.doctorName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return IconButton(
                            onPressed: () => rating.value = star,
                            icon: Icon(
                              star <= rating.value
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.terracottaSecondary,
                              size: 34,
                            ),
                          );
                        }),
                      ),
                      if (rating.value > 0)
                        Center(
                          child: Text(
                            ratingLabels[rating.value]!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 28),
                      Text('Personal reflection (optional)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: comment,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'What stood out about your consultation?',
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: rating.value == 0
                              ? null
                              : () {
                                  submitted.value = true;
                                },
                          child: const Text('Submit care feedback'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Fluttertoast.showToast(msg: 'Feedback skipped');
                            Navigator.pop(context);
                          },
                          child: const Text('Skip for now'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
