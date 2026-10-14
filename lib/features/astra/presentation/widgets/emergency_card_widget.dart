import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme.dart';
import '../../domain/entities/astra_card.dart';

/// The one hardcoded, non-negotiable card in Astra: shown for red-flag
/// symptoms, before or instead of any LLM reply. Never dismiss this
/// silently or replace its call-to-action with anything softer than
/// "call emergency services now". Styled per the design brief's one
/// exception to the calm palette: genuine medical urgency keeps the
/// clay/alert tone, unlike every other alert in the app.
class EmergencyCardWidget extends StatelessWidget {
  final EmergencyCard card;

  const EmergencyCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.clayAlertContainer,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.clayAlert.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.amberWarningContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded,
                    color: AppColors.clayAlert, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Clinical Safety Advisory',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.clayAlert,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.message,
            style: const TextStyle(
                fontSize: 13.5, color: AppColors.slateTextSecondary),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clayAlert,
                foregroundColor: AppColors.clayOnAlert,
              ),
              onPressed: () => launchUrl(Uri.parse('tel:112')),
              icon: const Icon(Icons.call),
              label: const Text('Call 112 now'),
            ),
          ),
        ],
      ),
    );
  }
}
