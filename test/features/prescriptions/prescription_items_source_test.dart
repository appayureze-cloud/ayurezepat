import 'package:doctro_patient/features/prescriptions/domain/entities/prescription_item.dart';
import 'package:doctro_patient/features/prescriptions/domain/prescription_items_source.dart';
import 'package:doctro_patient/model/v2/prescription_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealPrescriptionItemsSource', () {
    test('returns the backend items when present', () {
      final prescription = Prescription(items: const [
        PrescriptionItem(
          name: 'X',
          dose: '1',
          frequency: 'daily',
          durationDays: 3,
          timing: 'morning',
        ),
      ]);

      expect(
          RealPrescriptionItemsSource().itemsFor(prescription), hasLength(1));
    });

    test('returns empty when the backend has no items yet', () {
      final prescription = Prescription();
      expect(RealPrescriptionItemsSource().itemsFor(prescription), isEmpty);
    });
  });

  group('MockPrescriptionItemsSource', () {
    test('falls back to canned demo items when none are present', () {
      final prescription = Prescription();
      final items = MockPrescriptionItemsSource().itemsFor(prescription);
      expect(items, isNotEmpty);
    });

    test('prefers real items over the canned demo ones', () {
      final prescription = Prescription(items: const [
        PrescriptionItem(
          name: 'Real item',
          dose: '1',
          frequency: 'daily',
          durationDays: 3,
          timing: 'morning',
        ),
      ]);
      final items = MockPrescriptionItemsSource().itemsFor(prescription);
      expect(items, hasLength(1));
      expect(items.single.name, 'Real item');
    });
  });
}
