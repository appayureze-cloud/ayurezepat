/// Build-time configuration passed via `--dart-define` / `--dart-define-from-file`.
///
/// Nothing secret belongs here: this is compiled into the client binary and
/// can be extracted by anyone with the APK/IPA. Only client-restricted keys
/// (Android package+SHA1 / iOS bundle id restricted Google Maps keys) go
/// through this file. LLM keys, payment secrets and WhatsApp keys must never
/// be added here - the app talks to those providers only through our own
/// backend.
class Env {
  Env._();

  /// Google Maps key restricted (in Google Cloud Console) to this app's
  /// Android package name + signing SHA-1, used for the in-app map/places
  /// screens. Pass with:
  ///   --dart-define=GOOGLE_MAPS_API_KEY=xxx
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Feature flags for backend contracts this client was written against
  /// but the backend hasn't shipped yet. Each defaults to `true` (mock) so
  /// the UI keeps working end-to-end; flip to false with
  /// `--dart-define=USE_MOCK_PAYMENTS=false` once the real endpoint exists.
  /// See docs/backend/payments.md and docs/backend/case.md.
  static const bool useMockPayments = bool.fromEnvironment(
    'USE_MOCK_PAYMENTS',
    defaultValue: true,
  );

  static const bool useMockCases = bool.fromEnvironment(
    'USE_MOCK_CASES',
    defaultValue: true,
  );

  static const bool useMockAstra = bool.fromEnvironment(
    'USE_MOCK_ASTRA',
    defaultValue: true,
  );

  /// Shows canned demo prescription line items when the backend hasn't
  /// populated Prescription.items yet. See docs/backend/prescriptions.md.
  static const bool useMockPrescriptionItems = bool.fromEnvironment(
    'USE_MOCK_PRESCRIPTION_ITEMS',
    defaultValue: true,
  );

  static const bool useMockSmartOrders = bool.fromEnvironment(
    'USE_MOCK_SMART_ORDERS',
    defaultValue: true,
  );

  static const bool useMockHealthRecords = bool.fromEnvironment(
    'USE_MOCK_HEALTH_RECORDS',
    defaultValue: true,
  );

  /// See docs/backend/whatsapp.md. The client never talks to the WhatsApp
  /// BSP directly - only records the patient's opt-in/out choice with our
  /// backend, which relays it to the BSP.
  static const bool useMockWhatsappConsent = bool.fromEnvironment(
    'USE_MOCK_WHATSAPP_CONSENT',
    defaultValue: true,
  );

  /// The real Supabase-backed medicine reminders API on the Astra gateway
  /// (astra.ayureze.in/api/v1/api/reminders/*, confirmed live in a Phase 4
  /// audit - see docs/backend/astra.md) sends reminders over WhatsApp and
  /// tracks adherence server-side - a different mechanism from this app's
  /// local, flutter_local_notifications-based dose reminders. Defaults to
  /// mock so flipping this on is a deliberate choice, not an accident.
  static const bool useMockServerReminders = bool.fromEnvironment(
    'USE_MOCK_SERVER_REMINDERS',
    defaultValue: true,
  );

  /// The real documents API on the Astra gateway
  /// (astra.ayureze.in/api/v1/documents/*, confirmed live in a Phase 4
  /// audit - see docs/backend/astra.md). Merged into the health record
  /// timeline alongside encounters/prescriptions/reports from the main
  /// backend. Defaults to mock.
  static const bool useMockDocuments = bool.fromEnvironment(
    'USE_MOCK_DOCUMENTS',
    defaultValue: true,
  );
}
