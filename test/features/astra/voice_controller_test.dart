import 'package:doctro_patient/features/astra/presentation/voice_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('localeIdFor', () {
    test('maps english to en-US', () {
      expect(localeIdFor(AstraVoiceLanguage.english), 'en-US');
    });

    test('maps hindi to hi-IN', () {
      expect(localeIdFor(AstraVoiceLanguage.hindi), 'hi-IN');
    });
  });
}
