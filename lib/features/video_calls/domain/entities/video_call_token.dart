/// An Agora channel + token pair for one video call, from the real Astra
/// gateway (`POST /api/v1/video/generate-token`). See docs/backend/astra.md.
class VideoCallToken {
  final String channelName;
  final String token;

  const VideoCallToken({required this.channelName, required this.token});
}
