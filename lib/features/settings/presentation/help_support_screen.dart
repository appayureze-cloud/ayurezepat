import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme.dart';
import '../../../v2/ui/others/html_content_page.dart';
import '../../../v2/ui/widgets/header.dart';

const _faqs = [
  (
    'How do I book a doctor?',
    'Go to the Doctors tab or tap "Book" on a doctor card from Home, pick a date and time, and pay to confirm.',
  ),
  (
    'How do I talk to Astra?',
    'Open the Astra tab and describe how you\'re feeling. Astra can suggest remedies, recommend a doctor, or flag an emergency.',
  ),
  (
    'How do I get my medicines delivered?',
    'Use the Shop tab to search for a medicine, add it to your cart, and check out.',
  ),
  (
    'Is my health data private?',
    'Yes - see Settings > Privacy & Data for what we collect and how it\'s used.',
  ),
];

/// Matches the Stitch "Help & Support / About" screen
/// (ayureze_help_support_about/code.html): an FAQ accordion, a contact
/// row, and links to the existing legal pages.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Help & Support'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (question, answer) in _faqs)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: ExpansionTile(
                      shape:
                          const RoundedRectangleBorder(side: BorderSide.none),
                      title: Text(question,
                          style: Theme.of(context).textTheme.titleMedium),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(answer,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.support_agent,
                      color: AppColors.sagePrimary),
                  title: const Text('Contact support'),
                  subtitle: const Text('support@ayureze.in'),
                  onTap: () =>
                      launchUrl(Uri.parse('mailto:support@ayureze.in')),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.sagePrimary),
                  title: const Text('About AyurEze'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HtmlContentPage(apiKey: 'about', title: 'About Us'),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined,
                      color: AppColors.sagePrimary),
                  title: const Text('Terms & conditions'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HtmlContentPage(
                          apiKey: 'terms_and_conditions',
                          title: 'Terms & Conditions'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
