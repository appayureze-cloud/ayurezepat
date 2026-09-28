import 'package:doctro_patient/features/smart_orders/presentation/smart_order_reprompt_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nextRepromptTime is exactly 24 hours after now', () {
    final now = DateTime(2026, 1, 1, 9, 0);
    expect(nextRepromptTime(now), DateTime(2026, 1, 2, 9, 0));
  });
}
