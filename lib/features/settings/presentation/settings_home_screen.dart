import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/ui/widgets/profile_card.dart';

/// Matches the Stitch "Settings Home" screen
/// (ayureze_settings_home/code.html): a grouped list hub, reached from
/// Profile -> Settings, reusing the same soft-icon row style as Profile.
class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Settings'),
          const SizedBox(height: 8),
          const ProfileSectionCard(
            title: 'Account',
            route: 'SettingsAccount',
            icon: Icons.person_outline,
          ),
          const ProfileSectionCard(
            title: 'Notifications',
            route: 'SettingsNotifications',
            icon: Icons.notifications_none,
          ),
          const ProfileSectionCard(
            title: 'Privacy & Data',
            route: 'SettingsPrivacy',
            icon: Icons.privacy_tip_outlined,
          ),
          const ProfileSectionCard(
            title: 'Language & Preferences',
            route: 'SettingsLanguage',
            icon: Icons.language_outlined,
          ),
          const ProfileSectionCard(
            title: 'Help & Support',
            route: 'SettingsSupport',
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }
}
