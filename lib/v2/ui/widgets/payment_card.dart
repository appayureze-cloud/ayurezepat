import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class PaymentCard extends StatelessWidget {
  final ValueNotifier<String?> selectedPaymentType;
  final String title;
  final String value;

  const PaymentCard({
    required this.selectedPaymentType,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 0.5.h,
        ),
        child: Row(
          children: [
            // TODO: replace with payment type image
            Icon(
              Icons.credit_card_sharp,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              '$title',
              style: TextStyle(
                color: Palette.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            Radio(
              value: '$value',
              groupValue: selectedPaymentType.value,
              activeColor: Palette.primary,
              onChanged: (String? value) {
                if (value != null) selectedPaymentType.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
