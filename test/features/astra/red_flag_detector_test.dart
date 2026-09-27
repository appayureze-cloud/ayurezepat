import 'package:doctro_patient/features/astra/domain/red_flag_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RedFlagDetector', () {
    test('detects chest pain', () {
      expect(
        RedFlagDetector.detect(
            'I have severe chest pain and it won\'t go away'),
        contains(RedFlag.chestPain),
      );
    });

    test('detects stroke signs', () {
      expect(
        RedFlagDetector.detect(
            'My face drooping on one side and slurred speech'),
        containsAll([RedFlag.strokeSigns]),
      );
    });

    test('detects breathing difficulty', () {
      expect(
        RedFlagDetector.detect('I can\'t breathe properly since this morning'),
        contains(RedFlag.breathingDifficulty),
      );
    });

    test('detects suicidal thoughts', () {
      expect(
        RedFlagDetector.detect('Sometimes I just want to end my life'),
        contains(RedFlag.suicidalThoughts),
      );
    });

    test('detects heavy bleeding', () {
      expect(
        RedFlagDetector.detect('There is heavy bleeding from the wound'),
        contains(RedFlag.heavyBleeding),
      );
    });

    test('is case-insensitive', () {
      expect(
        RedFlagDetector.detect('CHEST PAIN since an hour'),
        contains(RedFlag.chestPain),
      );
    });

    test('detects multiple red flags in one message', () {
      final flags = RedFlagDetector.detect('chest pain and I can\'t breathe');
      expect(
          flags, containsAll([RedFlag.chestPain, RedFlag.breathingDifficulty]));
    });

    test('returns empty for an ordinary message', () {
      expect(RedFlagDetector.detect('I have a mild headache since yesterday'),
          isEmpty);
    });

    test('hasRedFlag mirrors detect', () {
      expect(RedFlagDetector.hasRedFlag('chest pain'), isTrue);
      expect(RedFlagDetector.hasRedFlag('I have a cold'), isFalse);
    });
  });
}
