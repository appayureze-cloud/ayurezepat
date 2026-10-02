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
  static String companionCaseHealthRecords(String caseId) =>
      'api/companion/case/$caseId/health_records';

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
}
