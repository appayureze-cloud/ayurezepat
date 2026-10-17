import 'package:flutter/material.dart';

import '../../../../theme.dart';
import '../../../../v2/ui/widgets/content_origin_badge.dart';
import '../../domain/entities/astra_card.dart';

class TipCardWidget extends StatelessWidget {
  final TipCard card;

  const TipCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sagePrimarySubtle,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined,
                  color: AppColors.sagePrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const ContentOriginBadge(origin: ContentOrigin.aiSuggested),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            card.body,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
