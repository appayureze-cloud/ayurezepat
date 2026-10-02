import 'package:doctro_patient/features/astra/data/mock_astra_repository.dart';
import 'package:doctro_patient/features/astra/domain/entities/astra_card.dart';
import 'package:doctro_patient/features/astra/domain/entities/astra_message.dart';
import 'package:doctro_patient/features/astra/presentation/astra_chat_notifier.dart';
import 'package:doctro_patient/features/astra/presentation/astra_localization.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AstraChatNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferenceHelper.init();
    notifier =
        AstraChatNotifier(MockAstraRepository(), AstraLocalization.empty());
  });

  group('AstraChatNotifier', () {
    test('init starts a session and adds the greeting as the first message',
        () async {
      await notifier.init();

      expect(notifier.initializing, isFalse);
      expect(notifier.error, isNull);
      expect(notifier.session, isNotNull);
      expect(notifier.messages, hasLength(1));
      expect(notifier.messages.single.role, AstraMessageRole.assistant);
      expect(notifier.messages.single.text, isNotEmpty);
    });

    test(
        'a red-flag message short-circuits to an emergency card without '
        'calling the repository', () async {
      await notifier.init();

      await notifier.sendUserMessage('I have severe chest pain right now');

      // greeting + user message + emergency reply
      expect(notifier.messages, hasLength(3));
      final lastMessage = notifier.messages.last;
      expect(lastMessage.role, AstraMessageRole.assistant);
      expect(lastMessage.cards, hasLength(1));
      expect(lastMessage.cards.single, isA<EmergencyCard>());
      expect(notifier.sending, isFalse);
    });

    test('an ordinary message streams a reply from the repository', () async {
      await notifier.init();

      await notifier.sendUserMessage('I have a mild headache');

      expect(notifier.messages, hasLength(3));
      final lastMessage = notifier.messages.last;
      expect(lastMessage.role, AstraMessageRole.assistant);
      expect(lastMessage.text, isNotEmpty);
      expect(notifier.sending, isFalse);
      expect(notifier.error, isNull);
    });

    test('does nothing for a blank message', () async {
      await notifier.init();
      final before = notifier.messages.length;

      await notifier.sendUserMessage('   ');

      expect(notifier.messages, hasLength(before));
    });
  });
}
