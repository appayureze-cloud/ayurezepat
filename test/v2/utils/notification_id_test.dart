import 'package:doctro_patient/v2/utils/notification_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notificationIdFor always fits a 32-bit signed int', () {
    for (final key in ['a', 'draft_123', 'a very long draft id string ' * 5]) {
      final id = notificationIdFor(key);
      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    }
  });

  test('notificationIdFor is stable for the same key', () {
    expect(notificationIdFor('draft_1'), notificationIdFor('draft_1'));
  });
}
