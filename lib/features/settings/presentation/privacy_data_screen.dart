import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../v2/ui/others/html_content_page.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/ui/widgets/profile_card.dart';

/// Matches the Stitch "Privacy & Data" screen
/// (ayureze_privacy_data/code.html). No "download my data" export
/// exists on the backend, so this links to the two real things that do:
/// the full privacy policy and the WhatsApp consent record.
class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Privacy & Data'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'We use your health information to connect you with doctors, '
              'our AI companion Astra, and your prescriptions and orders. '
              'You can manage what we share over WhatsApp below.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          const ProfileSectionCard(
            title: 'Manage WhatsApp consent',
            route: 'WhatsAppOptIn',
            icon: Icons.chat_outlined,
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HtmlContentPage(
                  apiKey: 'privacy_policy',
                  title: 'Privacy Policy',
                ),
              ),
            ),
            child: const ProfileSectionCard(
              title: 'Privacy policy',
              icon: Icons.description_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
