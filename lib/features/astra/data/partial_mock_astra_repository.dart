import 'dart:io';

import '../domain/astra_repository.dart';
import '../domain/entities/astra_recommendations.dart';
import '../domain/entities/astra_reply_event.dart';
import '../domain/entities/astra_session.dart';
import '../domain/entities/astra_voice_result.dart';
import '../domain/entities/care_plan.dart';
import '../domain/entities/checkin_result.dart';
import '../domain/entities/medicine_info.dart';
import '../domain/entities/triage_result.dart';
import 'astra_repository_impl.dart';
import 'mock_astra_repository.dart';

/// Routes every call to the real backend except [checkin] and
/// [ackReminder], confirmed by a live `curl` against
/// `https://ayureze.org/api/astra/...` on 2026-10-15 to 404 at the Laravel
/// router level ("The route ... could not be found") - i.e. the routes
/// don't exist yet, not just the referenced case/reminder. Those two stay
/// on [MockAstraRepository] so the daily check-in and medication reminder
/// ack flows keep working instead of failing every time. See
/// docs/backend/astra.md.
class PartialMockAstraRepository implements AstraRepository {
  final AstraRepositoryImpl _real;
  final MockAstraRepository _mock = MockAstraRepository();

  PartialMockAstraRepository(this._real);

  @override
  Future<AstraSession> createSession() => _real.createSession();

  @override
  Future<AstraSession> getSession(String sessionId) =>
      _real.getSession(sessionId);

  @override
  Stream<AstraReplyEvent> sendMessage(String sessionId, String text) =>
      _real.sendMessage(sessionId, text);

  @override
  Future<AstraVoiceResult> sendVoice(String sessionId, File audio) =>
      _real.sendVoice(sessionId, audio);

  @override
  Future<TriageResult> triage(String caseId) => _real.triage(caseId);

  @override
  Future<AstraRecommendations> recommendations(String caseId) =>
      _real.recommendations(caseId);

  @override
  Future<CarePlan> plan(String caseId) => _real.plan(caseId);

  @override
  Future<CheckinResult> checkin(String caseId, {required int symptomScore}) =>
      _mock.checkin(caseId, symptomScore: symptomScore);

  @override
  Future<void> ackReminder(String reminderId, String status) =>
      _mock.ackReminder(reminderId, status);

  @override
  Future<MedicineInfo> medicineInfo(String medicineId) =>
      _real.medicineInfo(medicineId);

  @override
  Future<void> resolveCase(String caseId) => _real.resolveCase(caseId);
}
