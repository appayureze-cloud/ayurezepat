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
  static const String companionChat = 'api/companion/chat';
  static String companionJourneyStatus(String journeyId) =>
      'api/companion/journey/$journeyId/status';
}
