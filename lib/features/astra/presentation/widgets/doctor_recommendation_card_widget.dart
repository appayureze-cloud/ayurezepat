import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/Palette.dart';
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
        if (card.reason != null)
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Text(
              card.reason!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Palette.dark_grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        DoctorInfoCard_v2(doctor: card.doctor),
      ],
    );
  }
}
