import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
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

    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

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
        Fluttertoast.showToast(msg: 'Appointment booked with ${appointment.doctorName}');
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
      body: Column(
        children: [
          Header_v2(title: doctor.name),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: [
                if ((doctor.specialization ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(doctor.specialization!,
                        style: TextStyle(fontSize: 13.sp, color: Palette.dark_grey)),
                  ),
                Text('Consultation fee: ₹$_defaultConsultationFeeRupees',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                SizedBox(height: 2.h),
                Text('Select date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                SizedBox(height: 1.h),
                SizedBox(
                  height: 9.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => SizedBox(width: 2.w),
                    itemBuilder: (context, i) {
                      final d = dates[i];
                      final isSelected = DateFormat('yyyy-MM-dd').format(d) ==
                          DateFormat('yyyy-MM-dd').format(selectedDate.value);
                      return GestureDetector(
                        onTap: () => selectedDate.value = d,
                        child: Container(
                          width: 16.w,
                          decoration: BoxDecoration(
                            color: isSelected ? Palette.primary : Palette.lightGrey,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('EEE').format(d),
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: isSelected ? Colors.white : Palette.dark_grey)),
                              Text(DateFormat('d MMM').format(d),
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.black)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 2.h),
                Text('Available times', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                SizedBox(height: 1.h),
                if (loadingSlots.value)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Center(
                        child: SpinKitFadingCircle(color: Palette.primary, size: 5.h)),
                  )
                else if (slots.value.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: const Text('No open slots on this date'),
                  )
                else
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: slots.value.map((slot) {
                      final isSelected = slot == selectedSlot.value;
                      return GestureDetector(
                        onTap: () => selectedSlot.value = slot,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Palette.primary : Colors.white,
                            border: Border.all(
                                color: isSelected ? Palette.primary : Palette.lightGrey),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Text(slot,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isSelected ? Colors.white : Colors.black)),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: ButtonV2(
              label: booking.value ? 'Booking…' : 'Book & Pay',
              width: 100.w,
              onPressed: selectedSlot.value == null || booking.value ? null : confirmBooking,
            ),
          ),
        ],
      ),
    );
  }
}
