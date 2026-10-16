import 'package:dio/dio.dart';

import 'astra_fill_dtos.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';

/// Patient-facing AstraFill text intake (`POST /api/v1/astra-fill/
/// process-text` + `POST /api/v1/astra-fill/confirm`) - both confirmed
/// live by direct curl against astra.ayureze.in. `process-voice` exists
/// but is marked `deprecated` in the live OpenAPI spec (replaced by
/// `transcribe-voice` + `confirm-transcript`, a separate two-step flow not
/// built here yet), so this only covers typed intake.
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
}
