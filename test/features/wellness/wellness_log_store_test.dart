import 'package:doctro_patient/features/wellness/data/wellness_log_store.dart';
import 'package:doctro_patient/features/wellness/domain/entities/wellness_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WellnessLogStore', () {
    test('getAll returns an empty list when nothing has been logged', () async {
      expect(await WellnessLogStore.getAll(), isEmpty);
    });

    test('upsert then getAll round-trips a logged entry', () async {
      await WellnessLogStore.upsert(const WellnessEntry(
        dateKey: '2026-03-01',
        sleepHours: 7.5,
        mood: 4,
        updatedAt: '2026-03-01T09:00:00.000',
      ));

      final all = await WellnessLogStore.getAll();
      expect(all, hasLength(1));
      expect(all.first.dateKey, '2026-03-01');
      expect(all.first.sleepHours, 7.5);
    });

    test('upserting the same day replaces, not duplicates, the entry',
        () async {
      await WellnessLogStore.upsert(const WellnessEntry(
        dateKey: '2026-03-01',
        sleepHours: 6,
        updatedAt: '2026-03-01T08:00:00.000',
      ));
      await WellnessLogStore.upsert(const WellnessEntry(
        dateKey: '2026-03-01',
        sleepHours: 8,
        updatedAt: '2026-03-01T20:00:00.000',
      ));

      final all = await WellnessLogStore.getAll();
      expect(all, hasLength(1));
      expect(all.first.sleepHours, 8);
    });

    test('getAll sorts most recent day first', () async {
      await WellnessLogStore.upsert(
          const WellnessEntry(dateKey: '2026-03-01', updatedAt: ''));
      await WellnessLogStore.upsert(
          const WellnessEntry(dateKey: '2026-03-03', updatedAt: ''));
      await WellnessLogStore.upsert(
          const WellnessEntry(dateKey: '2026-03-02', updatedAt: ''));

      final all = await WellnessLogStore.getAll();
      expect(all.map((e) => e.dateKey).toList(),
          ['2026-03-03', '2026-03-02', '2026-03-01']);
    });

    test('getForDate finds the entry matching that calendar day', () async {
      await WellnessLogStore.upsert(const WellnessEntry(
        dateKey: '2026-03-05',
        movementMinutes: 25,
        updatedAt: '',
      ));

      final found = await WellnessLogStore.getForDate(DateTime(2026, 3, 5));
      expect(found?.movementMinutes, 25);

      final notFound = await WellnessLogStore.getForDate(DateTime(2026, 3, 6));
      expect(notFound, isNull);
    });
  });
}
