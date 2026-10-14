import 'package:flutter/material.dart';

import '../../../theme.dart';

/// Matches the Stitch Profile screen's settings-row style
/// (ayureze_profile/code.html): a soft leading icon chip, label, trailing
/// chevron, no card border/shadow between consecutive rows.
class ProfileSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? route;

  const ProfileSectionCard(
      {required this.title, this.route, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route != null
          ? () {
              Navigator.pushNamed(context, '$route');
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              child: Icon(
                icon ?? Icons.settings,
                size: 18,
                color: AppColors.sagePrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.slateTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
