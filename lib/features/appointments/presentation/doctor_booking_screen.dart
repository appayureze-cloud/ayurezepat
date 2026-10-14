import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/doctor_summary.dart';
import 'appointment_service.dart';

// No per-doctor consultation fee exists in the `doctors` table yet (the
// only other place this was seen - app/doctors/doctor_routes.py's mock
// fallback - also just hardcodes 500). Flat default until a real fee field
// exists; the server, not this value, is still the source of truth for
// what Razorpay actually charges (via POST /finance/payments/create-order).
const int _defaultConsultationFeeRupees = 500;

/// Matches the Stitch "Doctor Detail / Booking" screen
/// (ayureze_doctor_detail_booking/code.html): date strip, slot-chip grid,
/// sticky bottom "Book appointment" pill button showing the fee.
class DoctorBookingScreen extends HookWidget {
  final DoctorSummary doctor;

  const DoctorBookingScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => AppointmentService());
    final selectedDate = useState(DateTime.now());
    final slots = useState<List<String>>([]);
    final selectedSlot = useState<String?>(null);
    final loadingSlots = useState(true);
    final booking = useState(false);

    final dates =
        List.generate(14, (i) => DateTime.now().add(Duration(days: i)));

    Future<void> loadSlots() async {
      loadingSlots.value = true;
      selectedSlot.value = null;
      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
        slots.value = await service.getSlots(doctor.doctorId, dateStr);
      } catch (e) {
        logger.e('Failed to load slots: $e');
        Fluttertoast.showToast(msg: 'Could not load available times');
        slots.value = [];
      } finally {
        loadingSlots.value = false;
      }
    }

    useEffect(() {
      loadSlots();
      return null;
    }, [selectedDate.value]);

    Future<void> confirmBooking() async {
      if (selectedSlot.value == null) return;
      booking.value = true;
      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
        final appointment = await service.bookAndPay(
          doctorId: doctor.doctorId,
          date: dateStr,
          time: selectedSlot.value!,
          amountRupees: _defaultConsultationFeeRupees,
        );
        Fluttertoast.showToast(
            msg: 'Appointment booked with ${appointment.doctorName}');
        if (context.mounted) Navigator.pop(context, true);
      } on AppointmentPaymentCancelledException {
        Fluttertoast.showToast(msg: 'Payment cancelled');
      } catch (e) {
        logger.e('Booking failed: $e');
        Fluttertoast.showToast(msg: 'Could not complete booking: $e');
      } finally {
        booking.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(title: 'Dr. ${doctor.name}'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.sagePrimaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: AppColors.sagePrimary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Dr. ${doctor.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge),
                              ),
                              if (doctor.isVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.verified,
                                      size: 18, color: AppColors.sagePrimary),
                                ),
                            ],
                          ),
                          if ((doctor.specialization ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(doctor.specialization!,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Select date',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final d = dates[i];
                      final isSelected = DateFormat('yyyy-MM-dd').format(d) ==
                          DateFormat('yyyy-MM-dd').format(selectedDate.value);
                      return GestureDetector(
                        onTap: () => selectedDate.value = d,
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sagePrimary
                                : AppColors.creamSurfaceLowest,
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.sagePrimary
                                    : AppColors.slateBorder),
                            borderRadius: AppRadius.roundedMd,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('EEE').format(d),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? AppColors.sageOnPrimary
                                          : AppColors.slateTextMuted)),
                              const SizedBox(height: 2),
                              Text(DateFormat('d MMM').format(d),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.sageOnPrimary
                                          : AppColors.slateTextPrimary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text('Available times',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (loadingSlots.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                        child: SpinKitFadingCircle(
                            color: AppColors.sagePrimary, size: 36)),
                  )
                else if (slots.value.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No open slots on this date',
                        style: TextStyle(color: AppColors.slateTextMuted)),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: slots.value.map((slot) {
                      final isSelected = slot == selectedSlot.value;
                      return GestureDetector(
                        onTap: () => selectedSlot.value = slot,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.sagePrimary
                                : AppColors.creamSurfaceLowest,
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.sagePrimary
                                    : AppColors.slateBorder),
                            borderRadius: AppRadius.roundedPill,
                          ),
                          child: Text(slot,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.sageOnPrimary
                                      : AppColors.slateTextPrimary)),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.creamSurfaceLowest,
                boxShadow: AppShadows.floatingNav,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Consultation fee',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.slateTextMuted)),
                      Text('₹$_defaultConsultationFeeRupees',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.sagePrimary)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: selectedSlot.value == null || booking.value
                        ? null
                        : confirmBooking,
                    child:
                        Text(booking.value ? 'Booking...' : 'Book appointment'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
