import 'package:flutter/material.dart';

import '../../../../theme.dart';
import '../../../../v2/ui/widgets/content_origin_badge.dart';
import '../../../../v2/ui/widgets/doctor_info_card.dart';
import '../../domain/entities/astra_card.dart';

/// Wraps the existing DoctorInfoCard_v2 (same widget the doctors-list and
/// home screens use) so tapping "Book" opens the same booking flow through
/// payment - Astra doesn't need its own booking UI.
class DoctorRecommendationCardWidget extends StatelessWidget {
  final DoctorRecommendationCard card;

  const DoctorRecommendationCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ContentOriginBadge(origin: ContentOrigin.aiSuggested),
            ],
          ),
        ),
        if (card.reason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              card.reason!,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.slateTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        DoctorInfoCard_v2(doctor: card.doctor, showRecommendedBadge: true),
      ],
    );
  }
}
