import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../domain/entities/astra_message.dart';
import 'astra_chat_notifier.dart';
import 'voice_controller.dart';

/// Matches the Stitch "Companion Voice Mode" screen
/// (ayureze_companion_voice_mode/code.html): a full-screen animated orb
/// representing Astra listening/speaking, with a live transcript and
/// mute/end controls. Shares the same [AstraChatNotifier] and
/// [VoiceController] the chat screen uses, rather than a separate voice
/// session, so anything said here lands in the same conversation.
class CompanionVoiceModeScreen extends HookWidget {
  final AstraChatNotifier notifier;
  final VoiceController voice;
  final AstraVoiceLanguage language;

  const CompanionVoiceModeScreen({
    required this.notifier,
    required this.voice,
    required this.language,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final listening = useState(false);
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    final pulse = useMemoized(
        () => Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
            ),
        [pulseController]);

    useListenable(notifier);

    final lastAssistantMessage = notifier.messages.isEmpty
        ? ''
        : notifier.messages.reversed
            .firstWhere(
              (m) => m.role == AstraMessageRole.assistant,
              orElse: () => notifier.messages.last,
            )
            .text;

    Future<void> toggleListening() async {
      if (listening.value) {
        await voice.stopListening();
        listening.value = false;
        return;
      }
      listening.value = true;
      await voice.startListening(
        language: language,
        onResult: (text) {
          listening.value = false;
          if (text.trim().isNotEmpty) notifier.sendUserMessage(text);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            ScaleTransition(
              scale:
                  listening.value ? pulse : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.sagePrimaryContainer,
                      AppColors.sagePrimary,
                    ],
                  ),
                ),
                child:
                    const Icon(Icons.psychology, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                listening.value
                    ? 'Listening...'
                    : (lastAssistantMessage.isEmpty
                        ? 'Hold the mic and tell Astra how you\'re feeling'
                        : lastAssistantMessage),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: toggleListening,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: listening.value
                          ? AppColors.clayAlert
                          : AppColors.sagePrimary,
                      child: Icon(
                        listening.value ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
