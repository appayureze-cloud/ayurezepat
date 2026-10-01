import '../../../v2/utils/logger.dart';
import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/entities/video_call_token.dart';
import '../domain/video_call_repository.dart';

class VideoCallException implements Exception {
  final String message;
  VideoCallException(this.message);

  @override
  String toString() => message;
}

/// Replaces the old `POST {Apis.baseUrl}generateAgoraToken` call (the main
/// Laravel backend - see the restored flow in videoCall.dart) with the real
/// Astra gateway's video API, confirmed live in a Phase 4 audit. The
/// request shape (`to_id`, `uid`) matches the old Laravel endpoint's body
/// closely enough that this reads as a deliberate reimplementation of the
/// same feature, not a new or separate one - see docs/backend/astra.md.
///
/// Unlike the gateway's reminders/documents routes, this one requires
/// HTTPBearer, so it goes through the same Firebase-token-exchange auth as
/// Astra chat.
class VideoCallRepositoryImpl implements VideoCallRepository {
  final AstraGatewayClient _gateway;

  VideoCallRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<VideoCallToken> generateToken({
    required String toId,
    int uid = 0,
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(
      AstraGatewayApis.videoGenerateToken,
      data: {'to_id': toId, 'uid': uid},
    );
    return parseVideoCallTokenResponse(response.data);
  }

  @override
  Future<String> getAppId() async {
    final dio = await _gateway.dio();
    final response = await dio.get(AstraGatewayApis.videoConfig);
    return parseVideoConfigAppId(response.data);
  }

  @override
  Future<void> addCallHistory({
    required String doctorId,
    required String patientId,
    required String channelName,
    required DateTime startTime,
    String status = 'initiated',
  }) async {
    final dio = await _gateway.dio();
    await dio.post(
      AstraGatewayApis.videoAddCallHistory,
      data: {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'channel_name': channelName,
        'start_time': startTime.toIso8601String(),
        'status': status,
      },
    );
  }
}

/// The response schema isn't fixed in the published spec; `cn` matches the
/// old Laravel response field name, `channel_name`/`channel` are other
/// plausible names for the same thing. Pulled out as a top-level function
/// so the defensive field-extraction can be unit tested without a real
/// network call.
VideoCallToken parseVideoCallTokenResponse(dynamic data) {
  if (data is! Map) {
    throw VideoCallException('Unexpected video token response: $data');
  }
  final channelName = data['cn'] ?? data['channel_name'] ?? data['channel'];
  final token = data['token'] ?? data['rtc_token'] ?? data['agora_token'];
  if (channelName == null || token == null) {
    logger.w('Video token response missing channel/token: $data');
    throw VideoCallException('Could not start the video call.');
  }
  return VideoCallToken(
    channelName: channelName.toString(),
    token: token.toString(),
  );
}

/// Same unconfirmed-schema situation as the token response. `agora_app_id`
/// matches the field name the main backend's `/setting` response already
/// used (`lib/model/v2/detail_setting_model.dart`); `app_id`/`appId` are
/// other plausible names for the same thing.
String parseVideoConfigAppId(dynamic data) {
  if (data is! Map) {
    throw VideoCallException('Unexpected video config response: $data');
  }
  final appId = data['agora_app_id'] ?? data['app_id'] ?? data['appId'];
  if (appId == null || appId.toString().isEmpty) {
    logger.w('Video config response missing app id: $data');
    throw VideoCallException('Could not load video call configuration.');
  }
  return appId.toString();
}
