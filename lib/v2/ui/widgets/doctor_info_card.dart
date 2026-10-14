import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/doctor_booking_screen.dart';
import '../../../theme.dart';

/// Matches the Stitch "Doctor Recommendation Card" bento style
/// (ayureze_astra_ai_chat/code.html) - used both inline in the Astra chat
/// and anywhere else a compact doctor card is needed.
class DoctorInfoCard_v2 extends HookWidget {
  final DoctorSummary doctor;

  /// Shows the "Recommended doctor" pill - only when Astra itself is the
  /// one suggesting this doctor (see DoctorRecommendationCardWidget),
  /// never in a plain directory listing.
  final bool showRecommendedBadge;

  /// Called with the booking result (true if booked) after the push to
  /// DoctorBookingScreen returns, so callers like DoctorListScreen can
  /// bubble that up to whoever's waiting to refresh (e.g.
  /// MyAppointmentsScreen's FAB flow).
  final void Function(bool booked)? onBookingResult;

  const DoctorInfoCard_v2({
    required this.doctor,
    this.showRecommendedBadge = false,
    this.onBookingResult,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLowest,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.slateBorder),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRecommendedBadge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurfaceLow,
                    borderRadius: AppRadius.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified,
                          size: 14, color: AppColors.sagePrimary),
                      SizedBox(width: 6),
                      Text(
                        'Recommended doctor',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sagePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (showRecommendedBadge) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                  imageUrl: doctor.photoUrl ?? '',
                  placeholder: (context, url) => Container(
                    height: 56,
                    width: 56,
                    color: AppColors.creamSurfaceLow,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 56,
                    width: 56,
                    color: AppColors.sagePrimaryContainer,
                    child:
                        const Icon(Icons.person, color: AppColors.sagePrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.name}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if ((doctor.specialization ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          doctor.specialization!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.slateBorderSubtle),
              ),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final booked = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DoctorBookingScreen(doctor: doctor)));
                    onBookingResult?.call(booked == true);
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Book appointment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
