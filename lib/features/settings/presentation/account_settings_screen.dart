import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/ui/widgets/profile_card.dart';

/// Matches the Stitch "Account Settings" screen
/// (ayureze_account_settings/code.html). Account deletion deliberately
/// stays only on the Profile screen, where its confirmation dialog and
/// API call already live - duplicating that dangerous action here would
/// mean two places to keep in sync for the same destructive flow.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Account'),
          const SizedBox(height: 8),
          const ProfileSectionCard(
            title: 'Edit profile',
            route: 'EditProfile',
            icon: Icons.edit_outlined,
          ),
          const ProfileSectionCard(
            title: 'Change password',
            route: 'ChangePassword',
            icon: Icons.lock_outline,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
            child: Text(
              'To delete your account, go to Profile and choose Delete Account.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
