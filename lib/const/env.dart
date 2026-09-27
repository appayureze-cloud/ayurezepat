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
}
