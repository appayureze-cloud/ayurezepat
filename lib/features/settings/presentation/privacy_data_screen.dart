import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/others/html_content_page.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/ui/widgets/profile_card.dart';
import '../../privacy/data/local_data_export_service.dart';
import '../../privacy/presentation/correction_request_screen.dart';
import '../../privacy/presentation/doctor_sharing_consent_screen.dart';

/// Matches the Stitch "Privacy & Data" screen
/// (ayureze_privacy_data/code.html), extended with the local-only controls
/// this app can actually offer: per-doctor sharing preference, a
/// local-data export, and a correction request routed to support - see
/// each feature's own doc comment for exactly what is and isn't backed by
/// a real backend endpoint.
class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Privacy & Data'),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'We use your health information to connect you with '
                    'doctors, our AI companion Astra, and your '
                    'prescriptions and orders. You can manage what we '
                    'share below.',
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
                      builder: (_) => const DoctorSharingConsentScreen(),
                    ),
                  ),
                  child: const ProfileSectionCard(
                    title: 'Doctor data sharing',
                    icon: Icons.medical_information_outlined,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    try {
                      await LocalDataExportService.exportAndOpen();
                    } catch (_) {
                      Fluttertoast.showToast(
                          msg: 'Could not export your data.');
                    }
                  },
                  child: const ProfileSectionCard(
                    title: 'Export my data',
                    icon: Icons.download_outlined,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CorrectionRequestScreen(),
                    ),
                  ),
                  child: const ProfileSectionCard(
                    title: 'Request a correction',
                    icon: Icons.edit_note_outlined,
                  ),
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
          ),
        ],
      ),
    );
  }
}
