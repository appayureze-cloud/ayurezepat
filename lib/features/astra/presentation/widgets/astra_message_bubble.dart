import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/Palette.dart';
import '../../domain/entities/astra_message.dart';
import 'astra_card_widget.dart';

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
        constraints: BoxConstraints(maxWidth: 80.w),
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isUser ? Palette.primary : Palette.lightGrey2,
          borderRadius: BorderRadius.circular(3.w),
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
                        color: isUser ? Palette.white : Palette.black,
                        fontSize: 13.5.sp,
                      ),
                    ),
                  ),
                  if (!isUser && onSpeak != null)
                    InkWell(
                      onTap: onSpeak,
                      child: Padding(
                        padding: EdgeInsets.only(left: 1.5.w),
                        child: Icon(Icons.volume_up,
                            size: 4.w, color: Palette.dark_grey),
                      ),
                    ),
                ],
              ),
            for (final card in message.cards) ...[
              if (message.text.isNotEmpty) SizedBox(height: 1.h),
              AstraCardWidget(card: card),
            ],
          ],
        ),
      ),
    );
  }
}
