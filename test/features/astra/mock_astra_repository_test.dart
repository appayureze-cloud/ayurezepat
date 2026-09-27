import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/astra/data/mock_astra_repository.dart';
import 'package:doctro_patient/features/astra/domain/astra_repository.dart';
import 'package:doctro_patient/features/astra/domain/entities/astra_card.dart';
import 'package:doctro_patient/features/astra/domain/entities/astra_reply_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockAstraRepository', () {
    late AstraRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferenceHelper.init();
      repository = MockAstraRepository();
    });

    test('createSession returns a session and caches the case id', () async {
      final session = await repository.createSession();

      expect(session.sessionId, isNotEmpty);
      expect(session.caseId, isNotEmpty);
      expect(session.greeting, isNotEmpty);
      expect(
          SharedPreferenceHelper.getString('active_case_id'), session.caseId);
    });

    test('sendMessage for a mild symptom streams text then a tip card',
        () async {
      final events =
          await repository.sendMessage('s1', 'I have a mild cold').toList();

      expect(events, isNotEmpty);
      expect(events.whereType<AstraTextChunk>(), isNotEmpty);
      final cardEvents = events.whereType<AstraCardEvent>().toList();
      expect(cardEvents, hasLength(1));
      expect(cardEvents.single.card, isA<TipCard>());
    });

    test('sendMessage for a non-mild symptom streams a doctor card', () async {
      final events = await repository
          .sendMessage('s1', 'I have severe abdominal pain for a week')
          .toList();

      final cardEvents = events.whereType<AstraCardEvent>().toList();
      expect(cardEvents, hasLength(1));
      expect(cardEvents.single.card, isA<DoctorRecommendationCard>());
    });
  });
}
