import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../const/env.dart';
import '../../../model/v2/prescription_response.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/pdf_downloader.dart';
import '../domain/entities/prescription_item.dart';
import '../domain/prescription_items_source.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final Prescription prescription;

  PrescriptionDetailScreen({required this.prescription, super.key});

  @override
  Widget build(BuildContext context) {
    final PrescriptionItemsSource source = Env.useMockPrescriptionItems
        ? MockPrescriptionItemsSource()
        : RealPrescriptionItemsSource();
    final items = source.itemsFor(prescription);

    return Scaffold(
      body: Column(
        children: [
          Header_v2(title: 'Prescription'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: [
                if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Center(
                      child: Text(
                        'A structured breakdown isn\'t available for this '
                        'prescription yet. Use the PDF below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Palette.dark_grey, fontSize: 13.sp),
                      ),
                    ),
                  )
                else
                  for (final item in items) _PrescriptionItemCard(item: item),
                if (prescription.treatmentRecommendation != null &&
                    prescription.treatmentRecommendation!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Treatment recommendation',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    prescription.treatmentRecommendation!,
                    style:
                        TextStyle(fontSize: 13.sp, color: Palette.dark_grey1),
                  ),
                ],
                SizedBox(height: 3.h),
                if (prescription.pdfPath != null)
                  ButtonV2(
                    label: 'View PDF',
                    onPressed: () => downloadAndOpenPdf(prescription.pdfPath!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionItemCard extends StatelessWidget {
  final PrescriptionItem item;

  const _PrescriptionItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.75.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.lightGrey),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${item.dose} · ${item.frequency} · ${item.durationDays} days · ${item.timing}',
            style: TextStyle(fontSize: 12.sp, color: Palette.dark_grey),
          ),
          if (item.instructions != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              item.instructions!,
              style: TextStyle(fontSize: 12.sp, color: Palette.dark_grey1),
            ),
          ],
        ],
      ),
    );
  }
}
