import 'package:dio/dio.dart';
import 'package:doctro_patient/features/astra/data/astra_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AstraRepositoryImpl repository;

  setUp(() {
    repository = AstraRepositoryImpl(Dio());
  });

  group('AstraRepositoryImpl.checkin', () {
    // No real backend endpoint exists for this (see the doc comment on
    // checkin() in astra_repository_impl.dart) - the escalation decision
    // is computed client-side, deterministically, with no network call,
    // matching the threshold MockAstraRepository already used.
    test('does not escalate for a low symptom score', () async {
      final result = await repository.checkin('case-1', symptomScore: 2);
      expect(result.escalate, isFalse);
      expect(result.nextAction, 'continue_plan');
    });

    test('escalates for a high symptom score', () async {
      final result = await repository.checkin('case-1', symptomScore: 5);
      expect(result.escalate, isTrue);
      expect(result.nextAction, 'escalate_to_doctor');
    });

    test('does not escalate at the threshold boundary', () async {
      final result = await repository.checkin('case-1', symptomScore: 3);
      expect(result.escalate, isFalse);
    });
  });
}
