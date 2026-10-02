import 'dart:io';

import 'entities/astra_recommendations.dart';
import 'entities/astra_reply_event.dart';
import 'entities/astra_session.dart';
import 'entities/astra_voice_result.dart';
import 'entities/care_plan.dart';
import 'entities/checkin_result.dart';
import 'entities/medicine_info.dart';
import 'entities/triage_result.dart';

/// The full Astra backend contract. Phase 1's UI only drives
/// [createSession], [sendMessage], [triage] and [recommendations]; the rest
/// exist so later phases (order drafts, reminders, daily check-ins) build
/// on a stable interface instead of bolting more methods on ad hoc.
abstract class AstraRepository {
  Future<AstraSession> createSession();

  Future<AstraSession> getSession(String sessionId);

  /// Streams the assistant's reply as it's generated. The stream completes
  /// when the backend closes the SSE connection.
  Stream<AstraReplyEvent> sendMessage(String sessionId, String text);

  Future<AstraVoiceResult> sendVoice(String sessionId, File audio);

  Future<TriageResult> triage(String caseId);

  Future<AstraRecommendations> recommendations(String caseId);

  Future<CarePlan> plan(String caseId);

  Future<CheckinResult> checkin(String caseId, {required int symptomScore});

  Future<void> ackReminder(String reminderId, String status);

  Future<MedicineInfo> medicineInfo(String medicineId);

  Future<void> resolveCase(String caseId);
}
