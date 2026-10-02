import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/time_slot_model.dart';
import '../../utils/logger.dart';

class BookingSection extends HookWidget {
  final Doctor doctor;
  final String title;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<String> selectedSession;
  final ValueNotifier<String> appointmentType;
  final ValueNotifier<String?> selectedTime;
  final ValueNotifier<bool> loading;

  const BookingSection(
      {required this.title,
      required this.selectedDate,
      required this.selectedSession,
      required this.selectedTime,
      required this.appointmentType,
      required this.doctor,
      required this.loading,
      super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<TimeOfDay>> morningSlots = useState([]);
    ValueNotifier<List<TimeOfDay>> eveningSlots = useState([]);
    ValueNotifier<List<TimeOfDay>> totalSlots = useState([]);

    Future<void> fetchSlots({required String session}) async {
      try {
        loading.value = true;
        Timeslot response =
            await RestClient(await RetroApi().dioData(context)).timeslot({
          'doctor_id': doctor.id,
          'date': DateFormat("yyyy-MM-dd").format(selectedDate.value),
        });
        if (response.success == true) {
          final slots = (response.data ?? []).map((e) {
            return TimeOfDay(
              hour: e.startTime!.split(" ")[1] == "am"
                  ? int.parse(e.startTime!.split(":")[0])
                  : int.parse(e.startTime!.split(":")[0]) + 12,
              minute: int.parse(e.startTime!.split(" ")[0].split(":")[1]),
            );
          });
          totalSlots.value = slots.toList();
          morningSlots.value = slots.where((e) => e.hour < 13).toList();
          eveningSlots.value = slots.where((e) => e.hour >= 13).toList();
        }
        loading.value = false;
      } catch (e) {
        logger.e(e);
        loading.value = false;
      }
    }

    useEffect(() {
      fetchSlots(session: selectedSession.value);
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title',
          style: TextStyle(
            color: Palette.black,
            fontSize: 16.sp,
          ),
        ),
        TableCalendar(
          firstDay: DateTime.now().add(const Duration(minutes: 30)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: selectedDate.value,
          selectedDayPredicate: (day) => isSameDay(selectedDate.value, day),
          calendarFormat: CalendarFormat.month,
          headerVisible: true,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            selectedDate.value = selectedDay;
          },
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Palette.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Palette.grey,
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
          ),
        ),
        SizedBox(height: 1.5.h),
        CallOptionsCard(
          doctor: doctor,
          selectedOption: appointmentType,
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(1.5.w),
          decoration: BoxDecoration(
            color: Palette.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(1.w),
          ),
          child: Row(
            children: ['Morning', 'Evening'].map((session) {
              final isSelected = session == selectedSession.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    selectedSession.value = session;
                    // selectedTime.value = null;
                    fetchSlots(session: selectedSession.value);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Palette.white : Palette.transparent,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Center(
                      child: Text(
                        session,
                        style: TextStyle(
                          color: isSelected ? Palette.primary : Palette.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 2.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // Format selected date
              DateFormat('MMM dd, yyyy').format(selectedDate.value),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              '${totalSlots.value.length} slots left',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Palette.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.5.h,
          children: (selectedSession.value == 'Morning'
                  ? morningSlots.value
                  : eveningSlots.value)
              .map((slot) {
            final formatted = slot.format(context);
            final isSelected = selectedTime.value == formatted;
            return GestureDetector(
              onTap: () => selectedTime.value = formatted,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected ? Palette.primary : Palette.white,
                  borderRadius: BorderRadius.circular(1.w),
                  border: Border.all(
                    color: Palette.grey.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Text(
                  formatted,
                  style: TextStyle(
                    color: isSelected ? Palette.white : Palette.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 1.5.h),
      ],
    );
  }
}

class CallOptionsCard extends HookWidget {
  final ValueNotifier<String> selectedOption;
  final Doctor doctor;

  const CallOptionsCard(
      {required this.selectedOption, required this.doctor, super.key});

  // default selection

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.white,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.05),
            blurRadius: 1.h,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CallOption(
            title: 'Video call',
            icon: Icons.videocam,
            price:
                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)}${doctor.videoAppointmentFees} / ${doctor.timeslot} mins',
            iconColor: selectedOption.value == 'video'
                ? Palette.primary
                : Palette.grey.withValues(alpha: .7),
            priceColor: selectedOption.value == 'video'
                ? Palette.black
                : Palette.grey.withValues(alpha: .7),
            selected: selectedOption.value == 'video',
            onTap: () => selectedOption.value = 'video',
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Palette.grey),
          _CallOption(
            title: 'On call',
            icon: Icons.call,
            price:
                '${SharedPreferenceHelper.getString(Preferences.currency_symbol)}${doctor.appointmentFees} / ${doctor.timeslot} mins',
            iconColor: selectedOption.value == 'audio'
                ? Palette.primary
                : Palette.grey.withValues(alpha: .6),
            priceColor: selectedOption.value == 'audio'
                ? Palette.black
                : Palette.grey.withValues(alpha: .6),
            selected: selectedOption.value == 'audio',
            onTap: () => selectedOption.value = 'audio',
          ),
        ],
      ),
    );
  }
}

class _CallOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String price;
  final Color iconColor;
  final Color priceColor;
  final bool selected;
  final VoidCallback onTap;

  const _CallOption({
    required this.title,
    required this.icon,
    required this.price,
    required this.iconColor,
    required this.priceColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.w),
            color: selected ? Palette.primary_bg : Colors.transparent,
          ), // Makes the area tappable
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Palette.black
                      : Palette.grey.withValues(alpha: .7),
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 6.w,
                    color: iconColor,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: priceColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
