import 'dart:io';

import 'package:dio/dio.dart';

import '../../../api/apis.dart';
import '../../../v2/utils/logger.dart';
import '../domain/astra_repository.dart';
import '../domain/entities/astra_recommendations.dart';
import '../domain/entities/astra_reply_event.dart';
import '../domain/entities/astra_session.dart';
import '../domain/entities/astra_voice_result.dart';
import '../domain/entities/care_plan.dart';
import '../domain/entities/checkin_result.dart';
import '../domain/entities/medicine_info.dart';
import '../domain/entities/triage_result.dart';
import 'astra_card_parser.dart';
import 'astra_dtos.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';
import 'astra_gateway_dtos.dart';

class AstraException implements Exception {
  final String message;
  AstraException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real Astra backend. Two different contracts are in play
/// here, both confirmed against astra.ayureze.in's live OpenAPI spec during
/// a Phase 4 connectivity audit - see docs/backend/astra.md:
///
/// - [createSession], [sendMessage] and [resolveCase] call the real,
///   confirmed "AI Wellness Companion" API on the Astra gateway
///   (astra.ayureze.in), via [AstraGatewayClient]. `dio` (the main app's
///   client, pointed at `Apis.baseUrl`/ayureze.org) is NOT used for these -
///   the gateway is a different host with its own Firebase-token-exchange
///   auth, not the app's regular bearer token.
/// - The rest of this class's methods ([getSession], [triage],
///   [recommendations], [plan], [checkin], [ackReminder], [medicineInfo])
///   are not called from any screen today and still target the original
///   speculative `{Apis.baseUrl}astra/...` contract from Phase 1, which was
///   never confirmed against a real backend - the audit found no exact
///   match for them on the real gateway. Each has a doc comment below
///   naming the closest real candidate endpoint, for whoever wires them up
///   next; don't assume the current implementation works.
class AstraRepositoryImpl implements AstraRepository {
  final Dio dio;
  final AstraGatewayClient _gateway;

  AstraRepositoryImpl(this.dio, [AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<AstraSession> createSession() async {
    final gatewayDio = await _gateway.dio();
    final userId = _gateway.cachedUserId;
    if (userId == null || userId.isEmpty) {
      throw AstraException('Could not resolve the Astra patient id.');
    }
    final response = await gatewayDio.post(
      AstraGatewayApis.companionJourneyStart,
      data: CompanionStartJourneyRequest(
        userId: userId,
        // The real API requires an upfront health concern to start a
        // journey; this client doesn't collect one before opening chat, so
        // it starts a generic journey and lets the patient state their
        // concern as their first message instead.
        healthConcern: 'General health query',
      ).toJson(),
    );
    final parsed = CompanionStartJourneyResponse.fromJson(response.data);
    if (parsed.success != true || parsed.journeyId == null) {
      throw AstraException(parsed.message);
    }
    return AstraSession(
      sessionId: parsed.journeyId!,
      caseId: parsed.journeyId!,
      greeting: parsed.welcomeMessage,
    );
  }

  /// No confirmed real endpoint - `GET /api/companion/journey/{id}`
  /// exists on the gateway but its response has no fixed schema in the
  /// published OpenAPI spec, so this still targets the old, unconfirmed
  /// contract. Not called from any screen currently.
  @override
  Future<AstraSession> getSession(String sessionId) async {
    final response = await dio.get('${Apis.baseUrl}astra/sessions/$sessionId');
    final parsed = CreateSessionResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Session not found');
    }
    return parsed.data!.toEntity();
  }

  @override
  Stream<AstraReplyEvent> sendMessage(String sessionId, String text) async* {
    final gatewayDio = await _gateway.dio();
    final response = await gatewayDio.post(
      AstraGatewayApis.companionChat,
      data: CompanionChatRequest(journeyId: sessionId, message: text).toJson(),
    );
    final parsed = CompanionChatResponse.fromJson(response.data);
    if (parsed.success != true) {
      throw AstraException('Astra could not reply right now.');
    }
    if (parsed.interventionType != null) {
      // Logged, not acted on: the real meaning of this field's values
      // isn't confirmed yet, and the client-side RedFlagDetector - not this
      // field - is the non-negotiable safety gate (see red_flag_detector.dart).
      logger.d('Astra companion intervention_type: ${parsed.interventionType}');
    }
    yield AstraTextChunk(parsed.response);

    // The backend's /api/companion/chat now attaches an optional
    // `metadata.cards[]` (see app/companion_suggestions.py) - a rule-based
    // first pass at a tip or doctor suggestion for this turn, in the same
    // `cards[]` shape astra_card_parser.dart already parses (previously
    // only reachable via MockAstraRepository). Read straight off the raw
    // response rather than CompanionChatResponse, which doesn't model
    // `metadata` - avoids a codegen rebuild for one optional field.
    final metadata = response.data is Map
        ? (response.data as Map)['metadata'] as Map<String, dynamic>?
        : null;
    final cardsJson = metadata?['cards'] as List<dynamic>?;
    if (cardsJson != null) {
      for (final cardJson in cardsJson) {
        if (cardJson is Map<String, dynamic>) {
          final card = parseAstraCard(cardJson);
          if (card != null) yield AstraCardEvent(card);
        }
      }
    }
  }

  @override
  Future<AstraVoiceResult> sendVoice(String sessionId, File audio) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audio.path),
    });
    final response = await dio.post(
      '${Apis.baseUrl}astra/sessions/$sessionId/voice',
      data: formData,
    );
    final parsed = VoiceResponse.fromJson(response.data);
    if (parsed.success != true) {
      throw AstraException(parsed.msg ?? 'Voice message failed');
    }
    return parsed.toEntity();
  }

  /// No confirmed real endpoint. Closest candidate:
  /// `POST /api/v1/brain/analyze_safety` ("Performs medical risk analysis")
  /// on the gateway, but its response has no fixed schema in the published
  /// spec, so the actual result shape isn't known. Not called from any
  /// screen currently.
  @override
  Future<TriageResult> triage(String caseId) async {
    final response =
        await dio.post('${Apis.baseUrl}astra/cases/$caseId/triage');
    final parsed = TriageResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Triage failed');
    }
    return parsed.data!.toEntity();
  }

  /// No confirmed real endpoint. Not called from any screen currently.
  @override
  Future<AstraRecommendations> recommendations(String caseId) async {
    final response =
        await dio.get('${Apis.baseUrl}astra/cases/$caseId/recommendations');
    final parsed = RecommendationsResponse.fromJson(response.data);
    if (parsed.success != true) {
      throw AstraException(parsed.msg ?? 'Could not load recommendations');
    }
    return parsed.data;
  }

  /// No confirmed real endpoint. Not called from any screen currently.
  @override
  Future<CarePlan> plan(String caseId) async {
    final response = await dio.get('${Apis.baseUrl}astra/cases/$caseId/plan');
    final parsed = CarePlanResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Could not load care plan');
    }
    return parsed.data!.toEntity();
  }

  /// No confirmed real endpoint - the closest candidate is
  /// `PUT /api/companion/case/progress` on the gateway, but its request
  /// schema wasn't checked closely enough to be confident it maps to a
  /// symptom-score check-in rather than something else (milestone
  /// progress?). Wires DailyCheckinScreen today via the old, unconfirmed
  /// contract.
  @override
  Future<CheckinResult> checkin(String caseId,
      {required int symptomScore}) async {
    final response = await dio.post(
      '${Apis.baseUrl}astra/cases/$caseId/checkins',
      data: CheckinRequest(symptomScore: symptomScore).toJson(),
    );
    final parsed = CheckinResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Check-in failed');
    }
    return parsed.data!.toEntity();
  }

  /// No confirmed real endpoint. The closest candidate,
  /// `POST /api/v1/api/reminders/adherence/log` (Supabase-backed medicine
  /// reminders), uses server-generated reminder ids, not the locally
  /// synthesized ones `reminderIdFor()` mints for this app's fully local,
  /// client-scheduled reminders (see dose_reminder_scheduler.dart) - the id
  /// spaces don't match, so this can't be wired as a drop-in swap. Wires
  /// main.dart's reminder Taken/Skip/Snooze handling today via the old,
  /// unconfirmed contract.
  @override
  Future<void> ackReminder(String reminderId, String status) async {
    await dio.post(
      '${Apis.baseUrl}astra/reminders/$reminderId/ack',
      data: AckReminderRequest(status: status).toJson(),
    );
  }

  /// No confirmed real endpoint. Not called from any screen currently.
  @override
  Future<MedicineInfo> medicineInfo(String medicineId) async {
    final response =
        await dio.get('${Apis.baseUrl}astra/medicines/$medicineId/info');
    final parsed = MedicineInfoResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Could not load medicine info');
    }
    return parsed.data!.toEntity();
  }

  /// Confirmed real endpoint: `PUT /api/companion/journey/{id}/status`
  /// ("Update journey status (active, monitoring, resolved, etc.)"), with
  /// `status` and `resolution_notes` as query parameters rather than a
  /// JSON body.
  @override
  Future<void> resolveCase(String caseId) async {
    final gatewayDio = await _gateway.dio();
    await gatewayDio.put(
      AstraGatewayApis.companionJourneyStatus(caseId),
      queryParameters: {'status': 'resolved'},
    );
  }
}
