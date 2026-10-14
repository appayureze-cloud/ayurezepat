import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/doctor_booking_screen.dart';
import '../../../theme.dart';

/// Matches the Stitch "Popular Doctors" carousel card
/// (ayureze_home/code.html): avatar, verified badge, specialization,
/// rating, and a "Book" pill button that opens the real booking screen.
class PopularDoctorCard extends HookWidget {
  final DoctorSummary doctor;

  const PopularDoctorCard({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLowest,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.sagePrimary.withOpacity(0.1)),
        boxShadow: AppShadows.subtleCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: doctor.photoUrl ?? '',
                  fit: BoxFit.cover,
                  height: 56,
                  width: 56,
                  errorWidget: (context, url, error) => Container(
                    height: 56,
                    width: 56,
                    color: AppColors.sagePrimaryContainer,
                    child:
                        const Icon(Icons.person, color: AppColors.sagePrimary),
                  ),
                  placeholder: (context, url) => Container(
                    height: 56,
                    width: 56,
                    color: AppColors.creamSurfaceLow,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Dr. ${doctor.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        if (doctor.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified,
                                size: 16, color: AppColors.sagePrimary),
                          ),
                      ],
                    ),
                    if ((doctor.specialization ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          doctor.specialization!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.slateBorderSubtle),
              ),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  doctor.isVerified ? 'Verified Vaidya' : 'Ayurvedic doctor',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.slateTextMuted),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DoctorBookingScreen(doctor: doctor)));
                  },
                  child: const Text('Book'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
