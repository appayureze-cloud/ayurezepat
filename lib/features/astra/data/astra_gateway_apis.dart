/// The real, live Astra backend - "Astra AI Unified Engine" - confirmed via
/// its published OpenAPI spec (https://astra.ayureze.in/openapi.json) during
/// a Phase 4 connectivity audit. This is a **separate host and separate auth
/// domain** from the main app backend (`Apis.baseUrl`, ayureze.org): it
/// issues its own JWT in exchange for a Firebase ID token rather than
/// accepting the Firebase token directly. See docs/backend/astra.md for the
/// full mapping between this client and the confirmed real contract.
class AstraGatewayApis {
  AstraGatewayApis._();

  static const String baseUrl = 'https://astra.ayureze.in/';

  static const String authSession = 'api/v1/auth/session';
  static const String authRefresh = 'api/v1/auth/refresh';
  static const String companionJourneyStart = 'api/companion/journey/start';
  static const String companionCaseCreate = 'api/companion/case/create';
  static const String companionChat = 'api/companion/chat';
  static String companionJourneyStatus(String journeyId) =>
      'api/companion/journey/$journeyId/status';
  static String companionJourneyGet(String journeyId) =>
      'api/companion/journey/$journeyId';
  static String companionJourneyUser(String userId) =>
      'api/companion/journey/user/$userId';
  static String companionCaseHealthRecords(String caseId) =>
      'api/companion/case/$caseId/health_records';
  static String companionCaseGet(String caseId) => 'api/companion/case/$caseId';

  /// Requires a real, doctor-created case_id (CreateCaseRequest in
  /// companion_api.py), not the journey-backed pseudo-case
  /// CaseRepositoryImpl otherwise uses - only callable once a doctor has
  /// actually created one via case/create.
  static const String companionCaseProgress = 'api/companion/case/progress';

  /// Attaches to a journey_id, so always callable (unlike case/progress
  /// above) - confirmed live via app/companion_api.py's MilestoneRequest.
  static const String companionMilestoneAdd = 'api/companion/milestone/add';

  /// Deprecated in the live spec in favour of `transcribe-voice` +
  /// `confirm-transcript` (not built here). `process-text` takes
  /// `application/x-www-form-urlencoded`, not JSON - confirmed live (a
  /// JSON body gets a 422). See AstraFillService for the full contract.
  static const String astraFillProcessText = 'api/v1/astra-fill/process-text';
  static const String astraFillConfirm = 'api/v1/astra-fill/confirm';

  /// Supabase-backed medicine reminders. Unlike the companion endpoints
  /// above, these are marked `security: none` in the published spec.
  static const String remindersCreate = 'api/v1/api/reminders/create';
  static const String remindersAdherenceLog =
      'api/v1/api/reminders/adherence/log';
  static const String remindersSnooze = 'api/v1/api/reminders/snooze';

  /// Document storage (lab reports, x-rays, prescriptions). Also
  /// `security: none` in the published spec.
  static String documentsForPatient(String patientId) =>
      'api/v1/documents/patient/$patientId';
  static String documentDownload(String documentId) =>
      'api/v1/documents/download/$documentId';

  /// Video consultation tokens (Agora, same provider the app already uses -
  /// see lib/VideoCall/videoCall.dart). Requires HTTPBearer, unlike the
  /// reminders/documents routes above.
  static const String videoGenerateToken = 'api/v1/video/generate-token';
  static const String videoConfig = 'api/v1/video/config';
  static const String videoAddCallHistory = 'api/v1/video/add-call-history';

  /// Shopify medicine catalog lookups. `security: none`. Response shape
  /// confirmed live (not guessed) during the Phase 4 audit.
  static String shopifyProductSearch(String medicineName) =>
      'api/v1/shopify/products/search/${Uri.encodeComponent(medicineName)}';

  /// Full Shopify product catalog (619 items confirmed live) - `security:
  /// none`, same as the single-item search above.
  static const String shopifyProductsAvailable =
      'api/v1/shopify/products/available';

  /// Smart order drafts (one auto-created per prescription - see
  /// docs/backend/smart-orders.md). The originally speculated
  /// `{Apis.baseUrl}smart_orders/{id}` (Laravel) routes return a genuine
  /// 404, never implemented there; the real backend lives in Astra's
  /// unified_prescription_workflow.py / smart_auto_cart.py instead.
  /// Patient-authenticated (HTTPBearer), unlike most routes in this file.
  static String smartOrderGet(String id) => 'api/v1/shopify/smart-orders/$id';
  static String smartOrderBought(String id) =>
      'api/v1/shopify/smart-orders/$id/bought';
  static String smartOrderIgnore(String id) =>
      'api/v1/shopify/smart-orders/$id/ignore';

  /// AI "autopilot" (proactive follow-up) consent + status. `security:
  /// none`. Response shapes confirmed live during the Phase 4 audit, not
  /// guessed.
  static const String autopilotConsent = 'api/v1/autopilot/consent';
  static String autopilotStatus(String patientId) =>
      'api/v1/autopilot/status/$patientId';

  /// FCM push token registration. `security: none`. Confirmed request
  /// schema, unconfirmed response schema.
  static const String notificationsStoreFcmToken =
      'api/v1/notifications/store-fcm-token';

  /// Appointment booking (app/appointment_routes.py) - real doctor
  /// availability/slots + an explicit booking/cancel action, decoupled from
  /// payment. HTTPBearer (Astra JWT), same as the finance routes below.
  static const String appointmentsDoctors = 'api/v1/appointments/doctors';
  static String appointmentsDoctorSlots(String doctorId) =>
      'api/v1/appointments/doctors/$doctorId/slots';
  static const String appointmentsBook = 'api/v1/appointments/book';
  static const String appointmentsMy = 'api/v1/appointments/my';
  static String appointmentsCancel(String consultationId) =>
      'api/v1/appointments/$consultationId/cancel';

  /// Consultation payment (app/finance_routes.py) - a dedicated, server-priced
  /// Razorpay order tied to a specific consultation_id, distinct from the
  /// main app backend's generic purpose/reference payment endpoint that
  /// PaymentService (lib/features/payments) talks to.
  static const String financeCreateOrder =
      'api/v1/finance/payments/create-order';
  static const String financeVerifyPayment = 'api/v1/finance/payments/verify';

  /// Patient cart & checkout (app/cart_routes.py) - add/remove items,
  /// checkout via a Shopify draft order + this same in-app Razorpay flow,
  /// verify payment, order history.
  static const String cartGet = 'api/v1/cart';
  static const String cartAddItem = 'api/v1/cart/items';
  static String cartRemoveItem(String productId) =>
      'api/v1/cart/items/$productId';
  static const String cartCheckout = 'api/v1/cart/checkout';
  static const String cartVerifyPayment = 'api/v1/cart/verify-payment';
  static const String cartOrders = 'api/v1/cart/orders';

  /// Supabase-backed patient profile creation (app/patients module) -
  /// requires HTTPBearer (Astra JWT), unlike most routes in this file.
  /// Confirmed in the published OpenAPI spec; not yet exercised from this
  /// client before the patient-registration best-effort call that uses it.
  static const String patientsRegister = 'api/v1/patients/register';
}
