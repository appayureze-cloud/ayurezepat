class Apis {
  /// Make sure wether you are using http or https
  /// Make sure wether you need /public/ in the base URL or not
  /// After changing here, also change in the [network_api.g.dart] file
  /// if that file doesn't exist, run the following command in the project terminal
  // dart run build_runner build --delete-conflicting-outputs
  static const String baseUrl =
      "https://ayureze.org/api/"; // Don't remove /api/

  static const String login = "login";
  static const String register = "register";
  static const String doctors_list = "doctors";
  static const String therapy_centers = "therapy_centers";
  static const String categories_list = "categories";
  static const String product_categories = "product_categories";
  static const String products = "products";
  static const String therapy_services = "therapy_services";
  static const String therapy_packages = "therapy_packages";
  static const String blogs = "blogs";
  static const String app_sections = "/app_sections/{key}";
  static const String medicine_home = "medicine_home";
  static const String appointment_home = "appointment_home";
  static const String therapy_home = "therapy_home";
  static const String blog_details = "blog_details/{id}";
  static const String treatment_list = "treatments";
  static const String book_appointment_list = "/appointments";
  static const String orders_list = "/orders_list/{status}/{page}/{per_page}";
  static const String user_book_appointment = "/book_appointment";
  static const String book_therapy_session = "book_session";
  static const String place_order = "orders";
  static const String therapy_sessions = "therapy_sessions";
  static const String get_appointment = "/get_appointment/{id}";
  static const String get_therapy_booking = "/get_session/{id}";
  static const String therapy_center_details = "/therapy_center_details/{id}";
  static const String product_details = "/product/{id}";
  static const String order_details = "/order/{id}";
  static const String cancel_order = "/orders/{orderId}/cancel";
  static const String check_otp = "check_otp";
  static const String addtocart = "addtocart";
  static const String cart = "cart";
  static const String google_sign_in = "/google_sign_in/{device_token}";
  static const String timeSlot = "timeslot";
  static const String add_address = "add_address";
  static const String show_address = "address";
  static const String delete_address = "delete_address/{id}";
  static const String user_detail = "user";
  static const String setting = "setting";
  static const String add_review = "add_review";
  static const String add_therapy_review = "add_therapy_review";
  static const String cancel_appointment = "cancel_appointment";
  static const String cancel_therapy_booking = "cancel_booking";
  static const String update_profile = "update_profile";
  static const String offer = "offers";
  static const String update_image = "update_image";
  static const String user_notification = "user_notification";
  static const String banner = "banner";
  static const String forgot_password = "forgot_password";
  static const String apply_offer = "check_offer";
  static const String change_password = "doctor_change_password";
  static const String resend_otp = "resendOtp/{id}";
  static const String prescription = "prescription/{id}";
  static const String videoCallToken = "generateAgoraToken";
  static const String AddVideoCallHistory = "add_call_history";
  static const String ShowVideoCallHistory = "video_call_history";
  static const String deleteAccount = "delete-account";

  // Server-priced Razorpay flow (Phase 0). See docs/backend/payments.md.
  static const String createPaymentOrder = "payments/orders";
  static const String verifyPayment = "payments/verify";

  // Case lifecycle (Phase 0 foundation for the Astra flow). See
  // docs/backend/case.md.
  static const String createCase = "cases";
  static const String getCase = "cases/{id}";
}
