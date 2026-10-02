import 'package:doctro_patient/features/astra/data/mock_astra_repository.dart';
import 'package:doctro_patient/features/astra/presentation/daily_checkin_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DailyCheckinNotifier notifier;

  setUp(() {
    notifier = DailyCheckinNotifier(MockAstraRepository(), 'case-1');
  });

  test('starts idle with the mildest score selected', () {
    expect(notifier.status, DailyCheckinStatus.idle);
    expect(notifier.symptomScore, 1);
  });

  test('setScore updates the selected score', () {
    notifier.setScore(4);
    expect(notifier.symptomScore, 4);
  });

  test('submitting a low score does not escalate', () async {
    notifier.setScore(2);
    await notifier.submit();

    expect(notifier.status, DailyCheckinStatus.done);
    expect(notifier.result, isNotNull);
    expect(notifier.result!.escalate, isFalse);
    expect(notifier.error, isNull);
  });

  test('submitting a high score escalates', () async {
    notifier.setScore(5);
    await notifier.submit();

    expect(notifier.status, DailyCheckinStatus.done);
    expect(notifier.result!.escalate, isTrue);
  });
}
