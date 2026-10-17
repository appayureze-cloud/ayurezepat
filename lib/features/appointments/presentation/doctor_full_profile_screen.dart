import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../domain/entities/doctor_summary.dart';
import 'doctor_booking_screen.dart';

/// Matches the Stitch "Doctor Full Profile" screen
/// (ayureze_doctor_full_profile/code.html): a large photo header and
/// the doctor's real fields. The mock's bio, qualifications list, and
/// patient-reviews section all need data DoctorSummary doesn't carry
/// (GET /api/v1/appointments/doctors returns only doctor_id, name,
/// specialization, is_face_verified, photo_url) - rather than invent a
/// bio or fake star ratings, this stays limited to what's real, with
/// the booking action still reachable.
class DoctorFullProfileScreen extends StatelessWidget {
  final DoctorSummary doctor;

  const DoctorFullProfileScreen({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ],
                        ),
                        ClipOval(
                          child: CachedNetworkImage(
                            height: 96,
                            width: 96,
                            fit: BoxFit.cover,
                            imageUrl: doctor.photoUrl ?? '',
                            errorWidget: (context, url, error) => Container(
                              height: 96,
                              width: 96,
                              color: AppColors.sagePrimaryContainer,
                              child: const Icon(Icons.person,
                                  size: 44, color: AppColors.sagePrimary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Dr. ${doctor.name}',
                                style:
                                    Theme.of(context).textTheme.displayMedium),
                            if (doctor.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.verified,
                                    color: AppColors.sagePrimary),
                              ),
                          ],
                        ),
                        if ((doctor.specialization ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(doctor.specialization!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        if (doctor.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.sagePrimarySubtle,
                                borderRadius: AppRadius.roundedPill,
                              ),
                              child: const Text('Verified Ayurvedic doctor',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.sagePrimary)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DoctorBookingScreen(doctor: doctor)),
                    ),
                    child: const Text('Book appointment'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
