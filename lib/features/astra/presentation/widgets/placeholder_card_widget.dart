import 'package:flutter/material.dart';

import '../../../../theme.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLow,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.slateTextPrimary),
          ),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.slateTextSecondary)),
        ],
      ),
    );
  }
}
