import 'entities/video_call_token.dart';

abstract class VideoCallRepository {
  Future<VideoCallToken> generateToken({required String toId, int uid = 0});
}
