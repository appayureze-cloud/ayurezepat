import 'package:flutter/material.dart';

import '../../../theme.dart';

/// Matches the Stitch "Permission requests" pattern
/// (ayureze_permission_requests/code.html): a single reusable screen for
/// the moment right before the OS permission dialog - large icon,
/// one-sentence plain-language reason, single "Continue" button. Call
/// this just before requesting a given permission (camera, microphone,
/// notifications, location) instead of asking the OS cold.
class PermissionRequestScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reason;
  final VoidCallback onContinue;

  const PermissionRequestScreen({
    required this.icon,
    required this.title,
    required this.reason,
    required this.onContinue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.sagePrimaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: AppColors.sagePrimary),
              ),
              const SizedBox(height: 32),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(reason,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
