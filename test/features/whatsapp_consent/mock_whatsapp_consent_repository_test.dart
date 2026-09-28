import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/whatsapp_consent/data/mock_whatsapp_consent_repository.dart';
import 'package:doctro_patient/features/whatsapp_consent/domain/whatsapp_consent_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockWhatsappConsentRepository', () {
    late WhatsappConsentRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferenceHelper.init();
      repository = MockWhatsappConsentRepository();
    });

    test('getConsent defaults to opted out with no consent timestamp',
        () async {
      final consent = await repository.getConsent();

      expect(consent.optedIn, isFalse);
      expect(consent.consentedAt, isNull);
    });

    test('setConsent(true) persists the opt-in and a timestamp', () async {
      final consent =
          await repository.setConsent(optedIn: true, phone: '+911234567890');

      expect(consent.optedIn, isTrue);
      expect(consent.consentedAt, isNotNull);
    });

    test('the choice survives a fresh repository instance', () async {
      await repository.setConsent(optedIn: true, phone: '+911234567890');
      final reloaded = MockWhatsappConsentRepository();

      final consent = await reloaded.getConsent();

      expect(consent.optedIn, isTrue);
    });

    test('opting back out clears the opted-in flag', () async {
      await repository.setConsent(optedIn: true, phone: '+911234567890');
      final consent =
          await repository.setConsent(optedIn: false, phone: '+911234567890');

      expect(consent.optedIn, isFalse);
    });
  });
}
