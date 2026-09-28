import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/entities/whatsapp_consent.dart';
import '../domain/whatsapp_consent_repository.dart';

/// Stands in for `POST /consents/whatsapp` until the backend ships (see
/// docs/backend/whatsapp.md), gated by Env.useMockWhatsappConsent. The
/// choice is still a real local consent record - just not synced anywhere -
/// so opting out actually sticks across app restarts in demos.
class MockWhatsappConsentRepository implements WhatsappConsentRepository {
  @override
  Future<WhatsappConsent> getConsent() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final consentedAt =
        SharedPreferenceHelper.getString(Preferences.whatsappConsentAt) ?? '';
    return WhatsappConsent(
      optedIn:
          SharedPreferenceHelper.getBoolean(Preferences.whatsappConsentOptedIn),
      consentedAt: consentedAt.isEmpty ? null : consentedAt,
    );
  }

  @override
  Future<WhatsappConsent> setConsent({
    required bool optedIn,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final consentedAt = DateTime.now().toIso8601String();
    await SharedPreferenceHelper.setBoolean(
        Preferences.whatsappConsentOptedIn, optedIn);
    await SharedPreferenceHelper.setString(
        Preferences.whatsappConsentAt, consentedAt);
    return WhatsappConsent(optedIn: optedIn, consentedAt: consentedAt);
  }
}
