import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';

/// Lets a patient describe something in their record that looks wrong.
/// There is no backend "submit a correction" endpoint, so this routes
/// through the one real support channel this app has
/// (support@ayureze.in, also used by HelpSupportScreen) rather than
/// fabricating a ticket system that doesn't exist.
class CorrectionRequestScreen extends StatefulWidget {
  const CorrectionRequestScreen({super.key});

  @override
  State<CorrectionRequestScreen> createState() =>
      _CorrectionRequestScreenState();
}

class _CorrectionRequestScreenState extends State<CorrectionRequestScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final description = _controller.text.trim();
    if (description.isEmpty) return;
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@ayureze.in',
      queryParameters: {
        'subject': 'Data correction request',
        'body': 'I would like the following corrected in my AyurEze '
            'record:\n\n$description',
      },
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not open your email app. Please email support@ayureze.in directly.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Request a correction'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Describe what looks wrong in your record (e.g. a '
                  'profile detail, an allergy, or something in a '
                  'prescription). This opens your email app addressed to '
                  'our support team - nothing is sent automatically.',
                  style: TextStyle(color: AppColors.slateTextSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'What needs to be corrected?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _send,
                    child: const Text('Email support'),
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
