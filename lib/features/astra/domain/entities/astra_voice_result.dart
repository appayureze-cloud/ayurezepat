/// `POST /astra/sessions/{id}/voice`. `ttsUrl` points at backend-hosted
/// audio for playback; if absent (or unreachable) the client falls back to
/// local flutter_tts for [reply].
class AstraVoiceResult {
  final String transcript;
  final String reply;
  final String? ttsUrl;

  const AstraVoiceResult({
    required this.transcript,
    required this.reply,
    this.ttsUrl,
  });
}
