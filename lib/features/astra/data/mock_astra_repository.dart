import 'dart:io';
import 'dart:math';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../appointments/domain/entities/doctor_summary.dart';
import '../domain/astra_repository.dart';
import '../domain/entities/astra_card.dart';
import '../domain/entities/astra_recommendations.dart';
import '../domain/entities/astra_reply_event.dart';
import '../domain/entities/astra_session.dart';
import '../domain/entities/astra_voice_result.dart';
import '../domain/entities/care_plan.dart';
import '../domain/entities/checkin_result.dart';
import '../domain/entities/medicine_info.dart';
import '../domain/entities/triage_result.dart';

/// Stands in for the backend's Astra endpoints until they exist (see
/// docs/backend/astra.md), gated by Env.useMockAstra. Gives simple
/// keyword-driven canned replies so the chat screen, triage routing and
/// card rendering can all be built and demoed before the real LLM pipeline
/// is live. This mock never needs to reproduce the emergency path - the
/// client's RedFlagDetector already intercepts those messages before they
/// would reach this repository.
class MockAstraRepository implements AstraRepository {
  final Random _random = Random();

  @override
  Future<AstraSession> createSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final caseId = 'mock_case_${_random.nextInt(1 << 32)}';
    // Share the same cached-case-id slot CaseRepository uses, so a doctor
    // card's booking flow (or any other feature reading the active case)
    // picks up the case Astra just started.
    await SharedPreferenceHelper.setString(Preferences.activeCaseId, caseId);
    return AstraSession(
      sessionId: 'mock_session_${_random.nextInt(1 << 32)}',
      caseId: caseId,
      greeting:
          "Hi, I'm Astra, your AI health assistant. I can help you figure out next steps, but I don't diagnose or prescribe. What's going on today?",
    );
  }

  @override
  Future<AstraSession> getSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return AstraSession(
      sessionId: sessionId,
      caseId: SharedPreferenceHelper.getString(Preferences.activeCaseId) ?? '',
      greeting: '',
    );
  }

  @override
  Stream<AstraReplyEvent> sendMessage(String sessionId, String text) async* {
    await Future.delayed(const Duration(milliseconds: 200));
    final lower = text.toLowerCase();
    final isMild = lower.contains('cold') ||
        lower.contains('headache') ||
        lower.contains('mild') ||
        lower.contains('cough');

    final reply = isMild
        ? "That sounds like it could be a mild, self-limiting issue. Here's a self-care tip while you keep an eye on it - if it gets worse or doesn't improve in a few days, let's get you in front of a doctor."
        : "Thanks for sharing that. Based on what you've described, I'd recommend speaking with a doctor rather than self-treating. Here are a couple of doctors I'd suggest.";

    for (final word in reply.split(' ')) {
      await Future.delayed(const Duration(milliseconds: 15));
      yield AstraTextChunk('$word ');
    }

    if (isMild) {
      yield const AstraCardEvent(TipCard(
        title: 'Rest and fluids',
        body:
            'Get plenty of rest, stay hydrated, and monitor your temperature. '
            'See a doctor if symptoms last more than 3 days or get worse.',
      ));
    } else {
      // Deliberately a TipCard, not a DoctorRecommendationCard: that card
      // type always carries a real, directly-bookable Doctor object (see
      // astra_card.dart), and DoctorInfoCard_v2's "book" tap passes it
      // straight through to MakeAppointment with no re-fetch or
      // validation against the real doctor list - select_payment_methods
      // .dart sends doctor.id verbatim as the booking's doctor_id. A fake
      // mock Doctor.id here would reach the real Laravel booking endpoint
      // and could silently collide with an unrelated real doctor's id -
      // confirmed during a doctor-assignment audit this mock predates.
      // Point the patient at the real Doctors tab instead of fabricating
      // a bookable doctor.
      yield const AstraCardEvent(TipCard(
        title: 'Worth seeing a doctor',
        body: "Based on what you've described, I'd recommend speaking "
            'with a doctor rather than self-treating. Check the Doctors '
            'tab to find and book one.',
      ));
    }
  }

  DoctorSummary _mockDoctor() => const DoctorSummary(
        doctorId: 'mock_doctor_1',
        name: 'Dr. Anita Rao',
        specialization: 'General Physician',
        isVerified: true,
      );

  @override
  Future<AstraVoiceResult> sendVoice(String sessionId, File audio) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AstraVoiceResult(
      transcript: '(mock transcript)',
      reply: "I heard you, but I'm running in offline demo mode right now.",
    );
  }

  @override
  Future<TriageResult> triage(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const TriageResult(
        route: TriageRoute.doctor, specialty: 'General Medicine');
  }

  @override
  Future<AstraRecommendations> recommendations(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return AstraRecommendations(doctors: [_mockDoctor()]);
  }

  @override
  Future<CarePlan> plan(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const CarePlan();
  }

  @override
  Future<CheckinResult> checkin(String caseId,
      {required int symptomScore}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return CheckinResult(
      nextAction: symptomScore <= 3 ? 'continue_plan' : 'escalate_to_doctor',
      escalate: symptomScore > 3,
    );
  }

  @override
  Future<void> ackReminder(String reminderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<MedicineInfo> medicineInfo(String medicineId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MedicineInfo(
      medicineId: medicineId,
      name: 'Sample Medicine',
      description: 'Mock medicine info for demo purposes.',
    );
  }

  @override
  Future<void> resolveCase(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await SharedPreferenceHelper.setString(
        Preferences.activeCaseStatus, 'resolved');
  }
}
