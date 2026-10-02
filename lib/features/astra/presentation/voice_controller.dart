import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../v2/utils/logger.dart';

enum AstraVoiceLanguage { english, hindi }

/// Maps our two supported voice languages to the locale ids speech_to_text
/// and flutter_tts expect. Kept as a pure mapping (no plugin calls) so it's
/// unit-testable without a platform channel.
String localeIdFor(AstraVoiceLanguage language) => switch (language) {
      AstraVoiceLanguage.english => 'en-US',
      AstraVoiceLanguage.hindi => 'hi-IN',
    };

/// Push-to-talk voice I/O for the Astra chat screen: hold the mic button to
/// speak (speech_to_text), Astra's replies can be read back (flutter_tts).
/// Thin wrapper over both plugins - the interesting logic (locale mapping,
/// red-flag screening) lives elsewhere and is unit tested there; this class
/// is exercised manually on-device since flutter_test has no real
/// microphone/TTS engine to drive.
class VoiceController extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _speechAvailable = false;
  bool get speechAvailable => _speechAvailable;

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (e) => logger.e('speech_to_text error: $e'),
      );
    } catch (e) {
      logger.e('speech_to_text init failed: $e');
      _speechAvailable = false;
    }
    notifyListeners();
    return _speechAvailable;
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Starts listening; calls [onResult] with the recognized text once the
  /// user stops speaking (or [stopListening] is called).
  Future<void> startListening({
    required AstraVoiceLanguage language,
    required void Function(String text) onResult,
  }) async {
    if (!_speechAvailable) {
      final ok = await init();
      if (!ok) return;
    }
    if (!await _ensureMicPermission()) return;

    await _speech.listen(
      localeId: localeIdFor(language),
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speech.stop();
    notifyListeners();
  }

  Future<void> speak(String text,
      {required AstraVoiceLanguage language}) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.setLanguage(localeIdFor(language));
      await _tts.speak(text);
    } catch (e) {
      logger.e('flutter_tts speak failed: $e');
    }
  }

  Future<void> stopSpeaking() => _tts.stop();

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }
}
