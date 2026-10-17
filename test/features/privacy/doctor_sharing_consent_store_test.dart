import 'package:doctro_patient/features/privacy/data/doctor_sharing_consent_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DoctorSharingConsentStore', () {
    test('getAll returns an empty list with no preferences set', () async {
      expect(await DoctorSharingConsentStore.getAll(), isEmpty);
    });

    test('setFor then getFor round-trips the preference', () async {
      await DoctorSharingConsentStore.setFor('doc1', 'Dr. Mehta', false);

      final consent = await DoctorSharingConsentStore.getFor('doc1');
      expect(consent?.doctorName, 'Dr. Mehta');
      expect(consent?.shareFullRecord, isFalse);
    });

    test('setFor replaces, not duplicates, an existing doctor preference',
        () async {
      await DoctorSharingConsentStore.setFor('doc1', 'Dr. Mehta', true);
      await DoctorSharingConsentStore.setFor('doc1', 'Dr. Mehta', false);

      final all = await DoctorSharingConsentStore.getAll();
      expect(all, hasLength(1));
      expect(all.first.shareFullRecord, isFalse);
    });

    test('tracks preferences for multiple doctors independently', () async {
      await DoctorSharingConsentStore.setFor('doc1', 'Dr. Mehta', false);
      await DoctorSharingConsentStore.setFor('doc2', 'Dr. Rao', true);

      expect((await DoctorSharingConsentStore.getFor('doc1'))?.shareFullRecord,
          isFalse);
      expect((await DoctorSharingConsentStore.getFor('doc2'))?.shareFullRecord,
          isTrue);
    });

    test('getFor returns null for a doctor with no preference set', () async {
      expect(await DoctorSharingConsentStore.getFor('unknown'), isNull);
    });
  });
}
