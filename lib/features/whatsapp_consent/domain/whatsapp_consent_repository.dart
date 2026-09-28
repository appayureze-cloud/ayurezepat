import 'entities/whatsapp_consent.dart';

abstract class WhatsappConsentRepository {
  Future<WhatsappConsent> getConsent();

  Future<WhatsappConsent> setConsent({
    required bool optedIn,
    required String phone,
  });
}
