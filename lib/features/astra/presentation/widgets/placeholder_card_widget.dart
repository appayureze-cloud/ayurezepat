import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/Palette.dart';
import '../../domain/entities/astra_card.dart';

/// Generic rendering for card kinds whose real screens land in a later
/// phase (order drafts in Phase 2, reminders in Phase 3). Keeps the chat
/// screen forward-compatible with the full card contract without building
/// UI ahead of the feature that needs it.
class PlaceholderCardWidget extends StatelessWidget {
  final String label;
  final String body;

  const PlaceholderCardWidget({
    required this.label,
    required this.body,
    super.key,
  });

  factory PlaceholderCardWidget.forOrder(OrderCard card) =>
      PlaceholderCardWidget(label: 'Order', body: card.summary);

  factory PlaceholderCardWidget.forReminder(ReminderCard card) =>
      PlaceholderCardWidget(
        label: 'Reminder',
        body: '${card.medicineName} at ${card.time}',
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Palette.lightGrey2,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
          ),
          SizedBox(height: 0.5.h),
          Text(body, style: TextStyle(fontSize: 13.sp)),
        ],
      ),
    );
  }
}
