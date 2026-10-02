import 'package:dio/dio.dart';
import 'package:doctro_patient/model/v2/account_delete_model.dart';
import 'package:doctro_patient/model/v2/apply_offer_model.dart';
import 'package:doctro_patient/model/v2/appointment_list_response.dart';
import 'package:doctro_patient/model/v2/book_appointments_model.dart';
import 'package:doctro_patient/model/v2/centers_list_response.dart';
import 'package:doctro_patient/model/v2/check_otp_model.dart';
import 'package:doctro_patient/model/v2/detail_setting_model.dart';
import 'package:doctro_patient/model/v2/doctor_list_response.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:doctro_patient/model/v2/login_model.dart';
import 'package:doctro_patient/model/v2/medicine/cart_list_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_category_list_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_details_response.dart'
    as mdr;
import 'package:doctro_patient/model/v2/medicine/medicine_details_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_list_response.dart';
import 'package:doctro_patient/model/v2/medicine/order_details_response.dart';
import 'package:doctro_patient/model/v2/medicine/order_list_response.dart';
import 'package:doctro_patient/model/v2/notification_model.dart'
    show UserNotification;
import 'package:doctro_patient/model/v2/register_model.dart';
import 'package:doctro_patient/model/v2/resend_otp_model.dart';
import 'package:doctro_patient/model/v2/review_model.dart';
import 'package:doctro_patient/model/v2/services_list_response.dart';
import 'package:doctro_patient/model/v2/show_address_model.dart';
import 'package:doctro_patient/model/v2/show_video_call_history_model.dart';
import 'package:doctro_patient/model/v2/therapy_booking_details_response.dart';
import 'package:doctro_patient/model/v2/time_slot_model.dart';
import 'package:doctro_patient/model/v2/update_profile_model.dart';
import 'package:doctro_patient/model/v2/update_user_image_model.dart';
import 'package:doctro_patient/model/v2/user_detail_model.dart';
import 'package:doctro_patient/model/v2/video_call_model.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

import '../features/case/data/case_dtos.dart';
import '../features/health_records/data/health_record_parser.dart';
import '../features/payments/data/payment_dtos.dart';
import '../features/smart_orders/data/smart_order_dtos.dart';
import '../model/v2/app_section_response.dart';
import '../model/v2/appointment_details_response.dart';
import '../model/v2/blog.dart';
import '../model/v2/blog_details.dart';
import '../model/v2/category_list_response.dart';
import '../model/v2/center_details_response.dart';
import '../model/v2/common_response.dart';
import '../model/v2/display_offer_model.dart';
import '../model/v2/forgot_password_model.dart';
import '../model/v2/packages_list_response.dart';
import '../model/v2/therapy_booking_list.dart';
import '../model/v2/therapy_home_response.dart';
import 'apis.dart';

part 'network_api.g.dart';

@RestApi(baseUrl: Apis.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @POST(Apis.login)
  Future<LoginResponse> loginRequest(@Body() body);

  @POST(Apis.register)
  Future<RegisterResponse> registerRequest(@Body() body);

  @POST(Apis.doctors_list)
  Future<DoctorListResponse> doctorList(@Body() body);

  @POST(Apis.products)
  Future<MedicinesListResponse> productsList(@Body() body);

  @POST(Apis.categories_list)
  Future<CategoryListResponse> categoriesList(@Body() body);

  @POST(Apis.product_categories)
  Future<MedicineCategoryListResponse> medicineCategoryList(@Body() body);

  @POST(Apis.therapy_centers)
  Future<CentersListResponse> centersList(@Body() body);

  @POST(Apis.therapy_services)
  Future<ServicesListResponse> servicesList(@Body() body);

  @POST(Apis.therapy_packages)
  Future<PackagesListResponse> packagesList(@Body() body);

  @GET(Apis.blogs)
  Future<BlogsResponse> blogList();

  @GET(Apis.app_sections)
  Future<AppSectionResponse> appSections(@Path() String key);

  @GET(Apis.medicine_home)
  Future<MedicineHomeResponse> medicineHomeData();

  @GET(Apis.appointment_home)
  Future<HomeResponse> appointmentHomeData(
      @Query("lat") double? lat, @Query("lang") double? lang);

  @GET(Apis.therapy_home)
  Future<TherapyHomeResponse> therapyHomeData(
      @Query("lat") double? lat, @Query("lang") double? lang);

  @GET(Apis.setting)
  Future<DetailSetting> settingRequest();

  @GET(Apis.blog_details)
  Future<BlogDetails> blogDetails(@Path() int? id);

  @GET(Apis.book_appointment_list)
  Future<AppointmentListResponse> appointmentsList();

  @GET(Apis.orders_list)
  Future<OrderListResponse> ordersList(
    @Path('status') String status,
    @Path('page') int page,
    @Path('per_page') int perPage,
  );

  @GET(Apis.therapy_sessions)
  Future<TherapyBookingListResponse> therapyBookingsList();

  @POST(Apis.user_book_appointment)
  Future<BookingResponse> bookAppointment(@Body() body);

  @POST(Apis.book_therapy_session)
  Future<BookingResponse> bookTherapySession(@Body() body);

  @POST(Apis.place_order)
  Future<CommonResponse> placeOrder(@Body() body);

  @GET(Apis.get_appointment)
  Future<AppointmentDetailsResponse> getAppointmentDetails(@Path() int? id);

  // Not live on the backend yet - see Apis.link_appointment_astra_case.
  @POST(Apis.link_appointment_astra_case)
  Future<CommonResponse> linkAppointmentAstraCase(@Body() body);

  @GET(Apis.get_therapy_booking)
  Future<TherapyBookingDetailsResponse> getTherapyBookingDetails(
      @Path() int? id);

  @GET(Apis.therapy_center_details)
  Future<CenterDetailsResponse> getCenterDetails(@Path() int? id);

  @GET(Apis.product_details)
  Future<mdr.MedicineDetailsResponse> getMedicineDetails(@Path() int? id);

  @GET(Apis.order_details)
  Future<OrderDetailsResposne> getOrderDetails(@Path() int? id);

  @POST(Apis.cancel_order)
  Future<CommonResponse> cancelOrder(@Path() int? orderId, @Body() body);

  @POST(Apis.check_otp)
  Future<CheckOtpModel> checkOtp(@Body() body);

  @POST(Apis.addtocart)
  Future<CommonResponse> addtocart(@Body() body);

  @GET(Apis.cart)
  Future<CartListResponse> getCartItems();

  @GET(Apis.google_sign_in)
  Future<CheckOtpModel> googleSignIn(
      @Path('device_token') String? device_token);

  @POST(Apis.timeSlot)
  Future<Timeslot> timeslot(@Body() body);

  @POST(Apis.add_address)
  Future<CommonResponse> addAddressRequest(@Body() body);

  @GET(Apis.show_address)
  Future<AddressListResponse> showAddressRequest();

  @GET(Apis.delete_address)
  Future<CommonResponse> deleteAddressRequest(@Path() int? id);

  @GET(Apis.user_detail)
  Future<UserDetail> userDetailRequest();

  @POST(Apis.add_review)
  Future<ReviewResponse> addAppointmentReview(@Body() body);

  @POST(Apis.add_therapy_review)
  Future<ReviewResponse> addTherapyReview(@Body() body);

  @POST(Apis.cancel_appointment)
  Future<CommonResponse> cancelAppointmentRequest(@Body() body);

  @POST(Apis.cancel_therapy_booking)
  Future<CommonResponse> cancelTherapyBooking(@Body() body);

  @POST(Apis.update_profile)
  Future<UpdateProfile> updateProfileRequest(@Body() body);

  @POST(Apis.offer)
  Future<CouponsResponse> fetchCoupons(@Body() body);

  @POST(Apis.update_image)
  Future<UpdateUserImage> updateUserImageRequest(@Body() body);

  @GET(Apis.user_notification)
  Future<UserNotification> notificationRequest();

  @POST(Apis.forgot_password)
  Future<ForgotPassword> forgotPasswordRequest(@Body() body);

  @POST(Apis.apply_offer)
  Future<ApplyOffer> applyOfferRequest(@Body() body);

  @POST(Apis.change_password)
  Future<CommonResponse> changePasswordRequest(@Body() body);

  @GET(Apis.resend_otp)
  Future<ResendOtp> resendOtpRequest(@Path() int? id);

  @POST(Apis.videoCallToken)
  Future<VideoCallModel> videoCallRequest(@Body() body);

  @GET(Apis.ShowVideoCallHistory)
  Future<ShowVideoCallHistoryModel> showVideoCallHistoryRequest();

  @GET(Apis.deleteAccount)
  Future<AccountDeleteModel> deleteAccount();

  @POST(Apis.createPaymentOrder)
  Future<CreatePaymentOrderResponse> createPaymentOrder(
      @Body() CreatePaymentOrderRequest body);

  @POST(Apis.verifyPayment)
  Future<VerifyPaymentResponse> verifyPayment(
      @Body() VerifyPaymentRequest body);

  @POST(Apis.createCase)
  Future<CaseResponse> createCase();

  @GET(Apis.getCase)
  Future<CaseResponse> getCase(@Path() String id);

  @GET(Apis.getSmartOrderDraft)
  Future<SmartOrderDraftResponse> getSmartOrderDraft(@Path() String id);

  @POST(Apis.markSmartOrderDraftBought)
  Future<CommonResponse> markSmartOrderDraftBought(@Path() String id);

  @POST(Apis.markSmartOrderDraftIgnored)
  Future<CommonResponse> markSmartOrderDraftIgnored(@Path() String id);

  @GET(Apis.getHealthRecordTimeline)
  Future<HealthRecordTimelineResponse> getHealthRecordTimeline(
      @Path() String caseId);

// @GET(Apis.insurers)
// Future<InsurersResponse> callInsurers();
}
