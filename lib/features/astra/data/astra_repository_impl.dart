import 'dart:convert';
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

class AstraException implements Exception {
  final String message;
  AstraException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real Astra endpoints. See docs/backend/astra.md.
class AstraRepositoryImpl implements AstraRepository {
  final Dio dio;

  AstraRepositoryImpl(this.dio);

  @override
  Future<AstraSession> createSession() async {
    final response = await dio.post('${Apis.baseUrl}astra/sessions');
    final parsed = CreateSessionResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Could not start Astra session');
    }
    return parsed.data!.toEntity();
  }

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
    final response = await dio.post<ResponseBody>(
      '${Apis.baseUrl}astra/sessions/$sessionId/messages',
      data: {'text': text},
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var buffer = '';
    await for (final line in stream) {
      if (line.isEmpty) continue;
      if (!line.startsWith('data:')) continue;
      buffer = line.substring(5).trim();
      if (buffer.isEmpty) continue;
      try {
        final json = jsonDecode(buffer) as Map<String, dynamic>;
        final event = _parseEvent(json);
        if (event != null) yield event;
      } catch (e) {
        logger.e('Failed to parse Astra SSE event: $e');
      }
    }
  }

  AstraReplyEvent? _parseEvent(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'chunk') {
      return AstraTextChunk(json['text'] as String? ?? '');
    }
    if (type == 'card') {
      final cardJson = json['card'] as Map<String, dynamic>?;
      if (cardJson == null) return null;
      final card = parseAstraCard(cardJson);
      return card == null ? null : AstraCardEvent(card);
    }
    return null;
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

  @override
  Future<CarePlan> plan(String caseId) async {
    final response = await dio.get('${Apis.baseUrl}astra/cases/$caseId/plan');
    final parsed = CarePlanResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw AstraException(parsed.msg ?? 'Could not load care plan');
    }
    return parsed.data!.toEntity();
  }

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

  @override
  Future<void> ackReminder(String reminderId, String status) async {
    await dio.post(
      '${Apis.baseUrl}astra/reminders/$reminderId/ack',
      data: AckReminderRequest(status: status).toJson(),
    );
  }

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

  @override
  Future<void> resolveCase(String caseId) async {
    await dio.post('${Apis.baseUrl}astra/cases/$caseId/resolve');
  }
}
