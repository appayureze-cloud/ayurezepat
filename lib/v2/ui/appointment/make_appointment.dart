import 'package:country_picker/country_picker.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/app_section_response.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:doctro_patient/model/v2/make_appointment.dart';
import 'package:doctro_patient/v2/ui/widgets/booking_section.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/help_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../utils/form_helper.dart';
import '../../../model/v2/show_address_model.dart';
import '../../utils/logger.dart';
import '../address/address_list.dart';
import '../widgets/doctor_details_card.dart';
import '../widgets/header.dart';
import 'confirm_appointment_details.dart';

class MakeAppointment extends HookWidget {
  final Doctor doctor;

  MakeAppointment({required this.doctor, super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<DateTime> selectedDate =
        useState(DateTime.now().add(Duration(days: 1)));
    ValueNotifier<String> selectedSession = useState('Morning');
    ValueNotifier<bool> loading = useState(false);
    ValueNotifier<String> appointmentType = useState('video');
    ValueNotifier<String?> selectedTime = useState(null);
    ValueNotifier<Address?> address = useState(null);
    ValueNotifier<Hospital?> hospital = useState(null);
    ValueNotifier<String> bookingFor = useState('myself');
    ValueNotifier<String> sideEffects = useState('no');
    ValueNotifier<List<Address>> addressList = useState([]);
    ValueNotifier<List<AppSection>> sections = useState([]);
    TextEditingController nameController = useTextEditingController(
        text: SharedPreferenceHelper.getString(FirestoreConstants.nickname));
    TextEditingController illnessController = useTextEditingController();
    TextEditingController noteController = useTextEditingController();
    TextEditingController ageController = useTextEditingController();
    TextEditingController phoneController = useTextEditingController(
        text: SharedPreferenceHelper.getString(Preferences.phone));
    TextEditingController phoneCodeController = useTextEditingController(
        text: SharedPreferenceHelper.getString(Preferences.phoneCode) ?? '+91');

    Future<void> fetchSections() async {
      loading.value = true;
      try {
        AppSectionResponse response =
            await RestClient(await RetroApi().dioData(context))
                .appSections('appointment');
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

    useEffect(() {
      if (selectedTime.value != null)
        debugPrint(
            '${DateFormat('dd-MM-yyyy').format(selectedDate.value)} ${DateFormat('hh:mm a').parse(selectedTime.value!)}');
    }, [selectedDate.value, selectedTime.value]);

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
                title: 'Make Appointment',
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
                    DoctorDetailsCard(doctor: doctor),
                    SizedBox(height: 3.h),
                    BookingSection(
                      loading: loading,
                      title: 'Appointment Schedules',
                      selectedDate: selectedDate,
                      selectedSession: selectedSession,
                      selectedTime: selectedTime,
                      doctor: doctor,
                      appointmentType: appointmentType,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Appointment Details',
                      style: TextStyle(
                        color: Palette.black,
                        fontSize: 16.sp,
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
                                'Appointment for',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomDropdown(
                                hint: 'Myself / Others',
                                value: bookingFor.value,
                                onChanged: (String? value) {
                                  bookingFor.value =
                                      value?.toLowerCase() ?? 'myself';
                                },
                                validator: (dynamic value) => value == null
                                    ? "Please select a value"
                                    : null,
                                items: ['myself', 'others'],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Patient Name',
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
                                'Hospital',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomDropdown<Hospital>(
                                hint: "Select Hospital",
                                value: hospital.value,
                                onChanged: (Hospital? newValue) {
                                  hospital.value = newValue;
                                },
                                validator: (dynamic value) => value == null
                                    ? "Please select valid address"
                                    : null,
                                items: doctor.hospital!,
                                labelKey: 'name',
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Illness',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTextField(
                                textCapitalization: TextCapitalization.words,
                                textInputType: TextInputType.text,
                                controller: illnessController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9 ]'))
                                ],
                                validator: (String? value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 1) {
                                    return "Please enter valid illness";
                                  }
                                  return null;
                                },
                                hint: 'Illness',
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
                              Text(
                                'Side Effects',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomDropdown<String>(
                                hint: 'Select',
                                value: sideEffects.value,
                                onChanged: (String? value) {
                                  sideEffects.value =
                                      value?.toLowerCase() ?? 'no';
                                },
                                validator: (dynamic value) => value == null
                                    ? "Please select a value"
                                    : null,
                                items: ['yes', 'no'],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Note',
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
                                textInputType: TextInputType.text,
                                controller: noteController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9,. ]'))
                                ],
                                maxLength: 40,
                                hint: 'Any problem to describe',
                              ),
                              SizedBox(height: 1.h),
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
                        logger.i(_formKey.currentState?.validate() ?? false);
                        if ((_formKey.currentState?.validate() ?? false) &&
                            selectedTime.value != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ConfirmAppointmentDetails(
                                          details: MakeAppointmentModal(
                                        bookingFor:
                                            bookingFor.value.toLowerCase(),
                                        name: nameController.text,
                                        age: ageController.text,
                                        sideEffects: sideEffects.value,
                                        address: address.value!,
                                        phoneCode: phoneCodeController.text,
                                        phone: phoneController.text,
                                        illness: illnessController.text,
                                        note: noteController.text,
                                        date: DateTime(
                                          selectedDate.value.year,
                                          selectedDate.value.month,
                                          selectedDate.value.day,
                                          DateFormat("hh:mm a")
                                              .parse('${selectedTime.value}')
                                              .hour,
                                          DateFormat("hh:mm a")
                                              .parse('${selectedTime.value}')
                                              .minute,
                                        ),
                                        hospital: hospital.value!,
                                        doctor: doctor,
                                        type: appointmentType.value,
                                      ))));
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
