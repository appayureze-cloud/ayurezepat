import 'package:doctro_patient/features/smart_orders/presentation/smart_order_reprompt_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nextRepromptTime is exactly 24 hours after now', () {
    final now = DateTime(2026, 1, 1, 9, 0);
    expect(nextRepromptTime(now), DateTime(2026, 1, 2, 9, 0));
  });

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
