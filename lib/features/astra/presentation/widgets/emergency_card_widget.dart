import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../const/Palette.dart';
import '../../domain/entities/astra_card.dart';

/// The one hardcoded, non-negotiable card in Astra: shown for red-flag
/// symptoms, before or instead of any LLM reply. Never dismiss this
/// silently or replace its call-to-action with anything softer than
/// "call emergency services now".
class EmergencyCardWidget extends StatelessWidget {
  final EmergencyCard card;

  const EmergencyCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Palette.red_bg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: Palette.red, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Palette.red, size: 5.w),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'This may be a medical emergency',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: Palette.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            card.message,
            style: TextStyle(fontSize: 13.sp, color: Palette.black),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.red,
                foregroundColor: Palette.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
              onPressed: () => launchUrl(Uri.parse('tel:112')),
              icon: const Icon(Icons.call),
              label: Text('Call 112 now', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
