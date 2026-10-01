import 'entities/video_call_token.dart';

abstract class VideoCallRepository {
  Future<VideoCallToken> generateToken({required String toId, int uid = 0});

  /// The Agora App ID, previously sourced from the main backend's
  /// `/setting` response (see docs/backend/astra.md) - that backend is
  /// unreachable, so this replaces it.
  Future<String> getAppId();

  /// Best-effort call-history record. Never blocks starting the call.
  Future<void> addCallHistory({
    required String doctorId,
    required String patientId,
    required String channelName,
    required DateTime startTime,
    String status = 'initiated',
  });
}
