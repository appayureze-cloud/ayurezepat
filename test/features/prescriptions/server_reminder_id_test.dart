import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/prescriptions/presentation/dose_reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferenceHelper.init();
  });

  group('serverReminderIdFor', () {
    test('returns null when no server reminder was cached', () {
      expect(serverReminderIdFor('presc1-item0-day0-dose0'), isNull);
    });

    test('returns null for an unrecognized reminder id format', () {
      expect(serverReminderIdFor('not-a-local-reminder-id'), isNull);
    });

    test(
        'returns the cached server id for the prescription/item the local '
        'reminder belongs to, regardless of day/dose', () async {
      await SharedPreferenceHelper.setString(
          'server_reminder_id_1-item0', 'server-abc');

      expect(serverReminderIdFor('presc1-item0-day0-dose0'), 'server-abc');
      expect(serverReminderIdFor('presc1-item0-day3-dose1'), 'server-abc');
    });

    test('does not confuse different items of the same prescription', () async {
      await SharedPreferenceHelper.setString(
          'server_reminder_id_1-item0', 'server-item0');
      await SharedPreferenceHelper.setString(
          'server_reminder_id_1-item1', 'server-item1');

      expect(serverReminderIdFor('presc1-item1-day0-dose0'), 'server-item1');
    });
  });
}
