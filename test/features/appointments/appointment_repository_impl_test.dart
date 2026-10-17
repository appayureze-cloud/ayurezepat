import 'package:doctro_patient/features/appointments/data/appointment_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dedupeSlots', () {
    test('removes the duplicate entries the real backend sends', () {
      final result =
          dedupeSlots(['09:00', '09:00', '09:30', '09:30', '10:00', '10:00']);

      expect(result, ['09:00', '09:30', '10:00']);
    });

    test('preserves order and leaves already-unique slots untouched', () {
      expect(dedupeSlots(['09:00', '09:30', '10:00']),
          ['09:00', '09:30', '10:00']);
    });

    test('handles an empty list', () {
      expect(dedupeSlots([]), isEmpty);
    });
  });
}
