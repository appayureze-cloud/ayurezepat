import 'package:flutter/material.dart';

import '../../../../theme.dart';
import '../../domain/entities/astra_message.dart';
import 'astra_card_widget.dart';

/// Matches the Stitch chat bubbles (ayureze_astra_ai_chat/code.html):
/// AI bubble on cream with a sharp top-left corner, patient bubble on
/// sage with a sharp top-right corner.
class AstraMessageBubble extends StatelessWidget {
  final AstraMessage message;
  final VoidCallback? onSpeak;

  const AstraMessageBubble({required this.message, this.onSpeak, super.key});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AstraMessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.sagePrimaryContainer
              : AppColors.creamSurfaceLowest,
          border:
              isUser ? null : Border.all(color: AppColors.slateBorderSubtle),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? AppRadius.lg : 4),
            topRight: Radius.circular(isUser ? 4 : AppRadius.lg),
            bottomLeft: const Radius.circular(AppRadius.lg),
            bottomRight: const Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isUser
                            ? AppColors.sageOnPrimaryContainer
                            : AppColors.slateTextPrimary,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (!isUser && onSpeak != null)
                    InkWell(
                      onTap: onSpeak,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.volume_up,
                            size: 18, color: AppColors.slateTextMuted),
                      ),
                    ),
                ],
              ),
            for (final card in message.cards) ...[
              if (message.text.isNotEmpty) const SizedBox(height: 8),
              AstraCardWidget(card: card),
            ],
          ],
        ),
      ),
    );
  }
}
