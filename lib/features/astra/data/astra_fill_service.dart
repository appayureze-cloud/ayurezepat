import 'dart:io';

import 'package:dio/dio.dart';

import 'astra_fill_dtos.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';

/// Patient-facing AstraFill intake, text and voice. `process-text` +
/// `confirm` (typed) and `transcribe-voice` + `confirm-transcript` (voice)
/// are both confirmed live by direct curl against astra.ayureze.in.
/// `process-voice` also exists but is marked `deprecated` in the live
/// OpenAPI spec in favour of the two-step voice flow used here.
///
/// `process-text` takes `text`/`user_id` as `application/x-www-form-
/// urlencoded`, not JSON - confirmed live (a JSON body gets a 422).
/// `confirm`'s `session_id` field is the patient's own user_id, not a
/// separate session concept - confirmed by testing both and checking the
/// confirmed record persisted under `astra-fill/patient/{user_id}/latest`.
class AstraFillService {
  final AstraGatewayClient _gateway;

  AstraFillService([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  Future<AstraFillExtraction> processText(String userId, String text) async {
    final dio = await _gateway.dio();
    final response = await dio.post(
      AstraGatewayApis.astraFillProcessText,
      data: {'text': text, 'user_id': userId},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return AstraFillExtraction.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> confirm({
    required String userId,
    required String extractionId,
    required HealthIntake confirmedData,
  }) async {
    final dio = await _gateway.dio();
    await dio.post(
      AstraGatewayApis.astraFillConfirm,
      data: {
        'session_id': userId,
        'extraction_id': extractionId,
        'confirmed_data': confirmedData.toJson(),
        'user_confirmed': true,
      },
    );
  }

  /// Phase 1 of the voice safety gate: STT only, no AI extraction yet.
  /// The caller MUST show the returned transcript to the patient for
  /// confirmation/editing before calling [confirmTranscript] - that's
  /// the whole point of this being two calls instead of one.
  Future<VoiceTranscriptPending> transcribeVoice(
    String userId,
    File audio, {
    String languageCode = 'en-IN',
  }) async {
    final dio = await _gateway.dio();
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audio.path),
      'user_id': userId,
      'language_code': languageCode,
    });
    final response = await dio.post(
      AstraGatewayApis.astraFillTranscribeVoice,
      data: formData,
    );
    return VoiceTranscriptPending.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// Phase 2: sends the patient-confirmed (or edited) transcript for AI
  /// extraction. Only runs once `userConfirmed` is true - the backend
  /// rejects the `pendingId` after it's 10 minutes old.
  Future<AstraFillExtraction> confirmTranscript({
    required String pendingId,
    required String userId,
    required String confirmedTranscript,
    String languageCode = 'en-IN',
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(
      AstraGatewayApis.astraFillConfirmTranscript,
      data: {
        'pending_id': pendingId,
        'user_id': userId,
        'confirmed_transcript': confirmedTranscript,
        'user_confirmed': true,
        'language_code': languageCode,
      },
    );
    return AstraFillExtraction.fromJson(response.data as Map<String, dynamic>);
  }
}
