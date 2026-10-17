import 'package:flutter/material.dart';

import '../../../theme.dart';

/// A small, consistent label distinguishing where a piece of content
/// came from, so a patient never has to guess whether something on
/// screen is Astra's own suggestion or an actual doctor's decision.
/// Shown once per screen/card rather than per sentence - the goal is a
/// clear signal at the point where confusion would matter, not visual
/// noise on every line of AI chat.
enum ContentOrigin {
  /// Astra's own output: a chat reply, a tip, a doctor recommendation, or
  /// an AI-extracted structured intake awaiting the patient's confirmation.
  aiSuggested,

  /// Content that reflects an actual doctor's decision: a prescription, a
  /// treatment plan, or a case diagnosis - not something Astra generated
  /// or can change.
  clinicianApproved,
}

class ContentOriginBadge extends StatelessWidget {
  final ContentOrigin origin;

  const ContentOriginBadge({required this.origin, super.key});

  @override
  Widget build(BuildContext context) {
    final isAi = origin == ContentOrigin.aiSuggested;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAi
            ? AppColors.amberWarning.withValues(alpha: 0.15)
            : AppColors.sagePrimarySubtle,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAi ? AppColors.amberWarning : AppColors.sagePrimary,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAi ? Icons.auto_awesome : Icons.verified_outlined,
            size: 12,
            color: isAi ? AppColors.amberWarning : AppColors.sagePrimary,
          ),
          const SizedBox(width: 4),
          Text(
            isAi ? 'Astra suggestion' : 'Doctor-approved',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAi ? AppColors.amberWarning : AppColors.sagePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
