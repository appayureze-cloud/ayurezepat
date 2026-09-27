import 'package:country_picker/country_picker.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/make_therapy_booking_modal.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_booking_confiirmation.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_card.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_package_card.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../database/form_helper.dart';
import '../../../model/v2/app_section_response.dart';
import '../../../model/v2/show_address_model.dart';
import '../../../model/v2/therapy_home_response.dart';
import '../../utils/logger.dart';
import '../address/address_list.dart';
import '../widgets/header.dart';
import '../widgets/help_card.dart';
import '../widgets/therapy_center_card.dart';

class TherapyBookingScreen extends HookWidget {
  final Centers center;
  final Services? service;
  final Packages? package;

  TherapyBookingScreen(
      {required this.center, this.service, this.package, super.key})
      : assert(
          ((service != null || package != null) ||
              (service != null) ^ (package != null)),
          'Either service or package must be provided, but not both.',
        );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<DateTime> selectedDate =
        useState(DateTime.now().add(Duration(days: 1)));
    ValueNotifier<TimeOfDay> selectedTime =
        useState(TimeOfDay(hour: 10, minute: 0));
    ValueNotifier<int> duration = useState(30);

    ValueNotifier<bool> loading = useState(false);

    ValueNotifier<String> bookingFor = useState('myself');
    TextEditingController nameController = useTextEditingController(
        text: SharedPreferenceHelper.getString(FirestoreConstants.nickname));
    TextEditingController ageController = useTextEditingController();
    TextEditingController phoneController = useTextEditingController(
        text: SharedPreferenceHelper.getString(Preferences.phone) ?? '');
    TextEditingController phoneCodeController = useTextEditingController(
        text: SharedPreferenceHelper.getString(Preferences.phoneCode) ?? '+91');
    ValueNotifier<Address?> address = useState(null);
    ValueNotifier<List<Address>> addressList = useState([]);
    ValueNotifier<List<AppSection>> sections = useState([]);

    Future<void> fetchSections() async {
      loading.value = true;
      try {
        AppSectionResponse response =
            await RestClient(await RetroApi().dioData(context))
                .appSections('therapy');
        sections.value.clear();
        if (response.success == true) {
          sections.value = response.data ?? [];
        }
        loading.value = false;
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<void> fetchAddresses() async {
      loading.value = true;
      AddressListResponse response;
      try {
        response = await RestClient(await RetroApi().dioData(context))
            .showAddressRequest();
        addressList.value.clear();
        if (response.success == true) {
          addressList.value = response.data ?? [];
        }
        loading.value = false;
      } catch (e) {
        logger.e('Error: $e');
        loading.value = false;
      }
    }

    useEffect(() {
      () async {
        await Future.wait([fetchAddresses(), fetchSections()]);
      }();
    }, []);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(
                title: 'Book therapy session',
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.ios_share_sharp,
                      color: Palette.black,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Center',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TherapyCenterCard(
                      center: center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${service != null ? 'therapy' : 'package'}'
                          .toSentenceCase(),
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (service != null)
                      TherapyCard(
                        service: service!,
                      ),
                    if (package != null) TherapyPackageCard(package: package!),
                    SizedBox(height: 3.h),
                    Text(
                      'Select Date & Time',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    TableCalendar(
                      availableGestures: AvailableGestures.horizontalSwipe,
                      firstDay: DateTime.now().add(const Duration(days: 1)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: selectedDate.value,
                      selectedDayPredicate: (day) =>
                          isSameDay(selectedDate.value, day),
                      calendarFormat: CalendarFormat.month,
                      headerVisible: true,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        selectedDate.value = selectedDay;
                      },
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
                    SizedBox(height: 2.h),
                    TimeDurationPicker(
                      selectedTime: selectedTime,
                      duration: duration,
                      maxHour:
                          DateFormat("hh:mm a").parse(center.endTime!).hour,
                      minHour:
                          DateFormat("hh:mm a").parse(center.startTime!).hour,
                      maxMin:
                          DateFormat("hh:mm a").parse(center.endTime!).minute,
                      minMin:
                          DateFormat("hh:mm a").parse(center.startTime!).minute,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.w)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 1.h),
                              Text(
                                'Booking for',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              DropdownButtonFormField(
                                hint: Text(
                                  'Myself / Others',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Palette.grey,
                                  ),
                                ),
                                value: bookingFor.value,
                                isExpanded: true,
                                iconSize: 21.sp,
                                onSaved: (String? value) {
                                  bookingFor.value =
                                      value?.toLowerCase() ?? 'myself';
                                },
                                onChanged: (String? value) {
                                  bookingFor.value =
                                      value?.toLowerCase() ?? 'myself';
                                },
                                validator: (dynamic value) => value == null
                                    ? "Please select a value"
                                    : null,
                                items: ['Myself', 'Others'].map((type) {
                                  return DropdownMenuItem<String>(
                                    child: new Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    value: type.toLowerCase(),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: nameController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9]'),
                                  )
                                ],
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 1) {
                                    return "Please enter valid name";
                                  }
                                  return null;
                                },
                                hint: 'Name',
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Age',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTextField(
                                textInputType: TextInputType.number,
                                controller: ageController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9]'))
                                ],
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 1) {
                                    return "Please enter valid age";
                                  }
                                  return null;
                                },
                                hint: 'Age',
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Address',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              GestureDetector(
                                onTap: () {
                                  if (addressList.value.length == 0) {
                                    FormHelper.showMessage(
                                      context,
                                      "No Address",
                                      "No any address, Please add address.",
                                      "No",
                                      () {
                                        Navigator.of(context).pop();
                                      },
                                      buttonText2: "Add",
                                      isConfirmationDialog: true,
                                      onPressed2: () {
                                        Navigator.of(context).pop();
                                        SharedPreferenceHelper.setString(
                                            'isWhere', "BookAppointment");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddressList(),
                                          ),
                                        ).then((_) {
                                          fetchAddresses();
                                        });
                                      },
                                    );
                                  }
                                },
                                child: CustomDropdown<Address>(
                                  hint: 'Address',
                                  value: address.value,
                                  onChanged: (Address? newValue) {
                                    address.value = newValue;
                                  },
                                  validator: (dynamic value) => value == null
                                      ? "Please select valid address"
                                      : null,
                                  items: addressList.value,
                                  labelKey: 'address',
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Phone',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 15.w,
                                    child: CustomTextField(
                                      textInputType: TextInputType.phone,
                                      readOnly: true,
                                      controller: phoneCodeController,
                                      hint: '+91',
                                      onTap: () {
                                        showCountryPicker(
                                          context: context,
                                          exclude: <String>['KN', 'MF'],
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            phoneCodeController.text =
                                                "+" + country.phoneCode;
                                          },
                                          countryListTheme:
                                              CountryListThemeData(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(3.h),
                                              topRight: Radius.circular(3.h),
                                            ),
                                            inputDecoration: InputDecoration(
                                              labelText: "Search",
                                              hintText:
                                                  "Start typing to search",
                                              prefixIcon:
                                                  const Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Palette.grey
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70.w,
                                    child: CustomTextField(
                                      textInputType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[a-zA-Z0-9]'))
                                      ],
                                      controller: phoneController,
                                      hint: 'Phone No',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    for (AppSection section in sections.value)
                      HelpCard(
                        section: section,
                      ),
                    SizedBox(height: 2.h),
                    ButtonV2(
                      label: 'Continue',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TherapyBookingConfirmation(
                                        booking: MakeTherapyBookingModal(
                                          bookingFor: bookingFor.value,
                                          name: nameController.text,
                                          age: ageController.text,
                                          address: address.value!,
                                          phoneCode: phoneCodeController.text,
                                          phone: phoneController.text,
                                          date: DateTime(
                                              selectedDate.value.year,
                                              selectedDate.value.month,
                                              selectedDate.value.day,
                                              selectedTime.value.hour,
                                              selectedTime.value.minute),
                                          center: center,
                                          package: package,
                                          service: service,
                                          duration: duration.value,
                                        ),
                                      )));
                        }
                      },
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDurationPicker extends HookWidget {
  TimeDurationPicker(
      {required this.selectedTime,
      required this.duration,
      required this.maxHour,
      required this.minHour,
      required this.maxMin,
      required this.minMin,
      super.key});

  final ValueNotifier<TimeOfDay> selectedTime;
  final ValueNotifier<int> duration;
  final int maxHour;
  final int minHour;
  final int maxMin;
  final int minMin;

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    void scrollToTime() {
      final offset = (selectedTime.value.hour - minHour) * 80.0;
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    String formatTime(int h, int m) {
      int hour = h ~/ 60;
      int min = m % 60;
      final isPM = hour >= 12;
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${'$min'.padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
    }

    useEffect(() {}, [duration.value]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToTime());
    }, []);
    return Column(
      children: [
        // Time & Duration Row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: Palette.primary_bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Time Display
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Time",
                      style: TextStyle(
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      formatTime(selectedTime.value.hour * 60,
                          selectedTime.value.minute),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                VerticalDivider(),
                // Duration Selector
                Column(
                  children: [
                    Text(
                      "Duration",
                      style: TextStyle(
                        fontSize: 15.sp,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if ((duration.value - 30) >= 30) {
                              duration.value -= 30;
                            }
                          },
                          icon: Icon(
                            Icons.remove,
                            size: 18.sp,
                          ),
                        ),
                        Text(
                          "${duration.value ~/ 60} hour ${duration.value % 60} min ${(duration.value ~/ 60) > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (((selectedTime.value.hour * 60) +
                                    selectedTime.value.minute +
                                    duration.value) <=
                                (maxHour * 60)) {
                              duration.value += 30;
                            }
                          },
                          icon: Icon(
                            Icons.add,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        // Time Ruler
        Stack(
          alignment: Alignment.center,
          children: [
            // Time Bar
            SizedBox(
              height: 6.h,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: ((maxHour - minHour) / 0.5).toInt() + 1,
                itemBuilder: (context, index) {
                  final hour = ((minHour + (index * 0.5)) * 60) ~/ 60;
                  final min = ((index * 0.5) * 60).toInt() % 60;
                  final isSelected = (((hour * 60) + min) >=
                          ((selectedTime.value.hour * 60) +
                              selectedTime.value.minute)) &&
                      (((hour * 60) + min) <
                          ((selectedTime.value.hour * 60) +
                              selectedTime.value.minute +
                              duration.value +
                              30));
                  return GestureDetector(
                    onTap: () {
                      selectedTime.value = TimeOfDay(hour: hour, minute: min);
                      if (((selectedTime.value.hour * 60) +
                              selectedTime.value.minute +
                              duration.value) >
                          (maxHour * 60)) {
                        duration.value = ((maxHour * 60) -
                            (selectedTime.value.hour * 60) +
                            selectedTime.value.minute);
                      }
                      scrollToTime();
                    },
                    child: Container(
                      width: 20.w,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? Palette.primary : Palette.grey,
                            width: 0.3.w,
                          ),
                        ),
                      ),
                      child: Text(
                        formatTime(hour * 60, min),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: isSelected ? Palette.primary : Palette.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Triangle Indicator
            Positioned(
              top: 0,
              child: Icon(
                Icons.arrow_drop_down,
                size: 4.5.h,
                color: Palette.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
