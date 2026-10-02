import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../const/Palette.dart';
import '../../domain/entities/astra_card.dart';

class TipCardWidget extends StatelessWidget {
  final TipCard card;

  const TipCardWidget({required this.card, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Palette.green_bg,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Palette.green, size: 4.w),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Palette.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            card.body,
            style: TextStyle(fontSize: 13.sp, color: Palette.dark_grey1),
          ),
        ],
      ),
    );
  }
}
