import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/ui/widgets/profile_card.dart';

/// Matches the Stitch "Notification Preferences" screen
/// (ayureze_notification_preferences/code.html). The mock's per-category
/// toggles (appointment reminders, dose reminders, daily check-in
/// nudges, promotional messages) have no backing preference store or
/// enforcement point in this app yet - dose/check-in reminders are
/// scheduled directly when the patient sets them, not gated by a global
/// switch - so faking toggles here would look functional while doing
/// nothing. This instead links to the two controls that are real: the
/// WhatsApp consent record (its own screen, already backed by the
/// server) and the OS-level notification permission.
class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Notifications'),
          const SizedBox(height: 8),
          const ProfileSectionCard(
            title: 'WhatsApp updates',
            route: 'WhatsAppOptIn',
            icon: Icons.chat_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              onTap: openAppSettings,
              borderRadius: AppRadius.roundedMd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.creamSurfaceLowest,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.slateBorderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.sagePrimarySubtle,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_outlined,
                          size: 18, color: AppColors.sagePrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Push notifications',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text('Manage in system settings',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.slateTextMuted),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
            child: Text(
              'Appointment and medication reminders are scheduled directly '
              'when you book an appointment or set up a prescription\'s '
              'reminders - there\'s no separate switch for those yet.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
