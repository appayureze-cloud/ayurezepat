import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../const/env.dart';
import '../../../model/v2/prescription_response.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/content_origin_badge.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/pdf_downloader.dart';
import '../domain/entities/prescription_item.dart';
import '../domain/prescription_items_source.dart';
import 'dose_reminder_scheduler.dart';

/// Matches the Stitch "Structured Prescription" screen
/// (ayureze_structured_prescription/code.html): a clean item list, with
/// the treatment-recommendation / dose-reminders actions styled as calm
/// callout cards rather than plain buttons.
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
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Prescription'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ContentOriginBadge(
                        origin: ContentOrigin.clinicianApproved),
                  ),
                ),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'A structured breakdown isn\'t available for this '
                        'prescription yet. Use the PDF below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.slateTextMuted),
                      ),
                    ),
                  )
                else
                  for (final item in items) _PrescriptionItemCard(item: item),
                if (prescription.treatmentRecommendation != null &&
                    prescription.treatmentRecommendation!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.sagePrimarySubtle,
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Treatment recommendation',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          prescription.treatmentRecommendation!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            'TherapyHome',
                            arguments: [
                              2,
                              prescription.treatmentRecommendation
                            ],
                          ),
                          child: const Text('Book treatment'),
                        ),
                      ],
                    ),
                  ),
                ],
                if (items.isNotEmpty && prescription.id != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            color: AppColors.sagePrimary),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Text('Get reminded to take each dose')),
                        TextButton(
                          onPressed: () async {
                            final prescriptionId = prescription.id!;
                            for (var i = 0; i < items.length; i++) {
                              await scheduleDoseReminders(
                                prescriptionId: prescriptionId,
                                itemIndex: i,
                                item: items[i],
                              );
                            }
                            Fluttertoast.showToast(
                              msg:
                                  'Reminders set for ${items.length} medicine(s)',
                            );
                          },
                          child: const Text('Set reminders'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (prescription.pdfPath != null)
                  OutlinedButton.icon(
                    onPressed: () => downloadAndOpenPdf(prescription.pdfPath!),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('View PDF'),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLowest,
        border: Border.all(color: AppColors.slateBorder),
        borderRadius: AppRadius.roundedLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.sagePrimarySubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 18, color: AppColors.sagePrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  '${item.dose} · ${item.frequency} · ${item.durationDays} days · ${item.timing}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.instructions != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.instructions!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
