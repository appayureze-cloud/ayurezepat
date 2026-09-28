import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/header.dart';
import '../data/astra_service.dart';
import '../domain/entities/astra_message.dart';
import 'astra_chat_notifier.dart';
import 'astra_localization.dart';
import 'daily_checkin_screen.dart';
import 'voice_controller.dart';
import 'widgets/astra_message_bubble.dart';

/// Astra: the AI health assistant tab. Bootstraps a chat session, then
/// hands off to [AstraChatBody] once the notifier is ready.
class AstraChatScreen extends HookWidget {
  const AstraChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = useState(AstraVoiceLanguage.english);
    final loc = useState(AstraLocalization.empty());
    final notifier = useState<AstraChatNotifier?>(null);
    final voice = useMemoized(() => VoiceController(), []);
    useEffect(() => voice.dispose, [voice]);

    Future<void> bootstrap() async {
      final dio = await RetroApi().dioData(context);
      final repository = AstraService.withDio(dio).repository;
      final localization = await AstraLocalization.load(language.value);
      loc.value = localization;
      final n = AstraChatNotifier(repository, localization);
      notifier.value = n;
      await n.init();
    }

    useEffect(() {
      bootstrap();
      return null;
    }, const []);

    useEffect(() {
      if (notifier.value != null) {
        AstraLocalization.load(language.value).then((l) {
          loc.value = l;
          notifier.value!.loc = l;
        });
      }
      return null;
    }, [language.value]);

    return Scaffold(
      body: Column(
        children: [
          Header_v2(
            title: 'Astra',
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
                ),
                icon: Icon(Icons.checklist, color: Palette.primary),
                tooltip: 'Daily check-in',
              ),
              TextButton(
                onPressed: () {
                  language.value = language.value == AstraVoiceLanguage.english
                      ? AstraVoiceLanguage.hindi
                      : AstraVoiceLanguage.english;
                },
                child: Text(
                  language.value == AstraVoiceLanguage.english
                      ? 'हिन्दी'
                      : 'EN',
                  style: TextStyle(fontSize: 12.sp, color: Palette.primary),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            color: Palette.primary_bg,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Text(
              loc.value.t('astra_disclaimer'),
              style: TextStyle(fontSize: 11.sp, color: Palette.dark_grey1),
            ),
          ),
          Expanded(
            child: notifier.value == null
                ? Center(
                    child:
                        SpinKitFadingCircle(color: Palette.primary, size: 6.h),
                  )
                : AstraChatBody(
                    notifier: notifier.value!,
                    voice: voice,
                    language: language,
                    loc: loc.value,
                  ),
          ),
        ],
      ),
    );
  }
}

class AstraChatBody extends HookWidget {
  final AstraChatNotifier notifier;
  final VoiceController voice;
  final ValueNotifier<AstraVoiceLanguage> language;
  final AstraLocalization loc;

  const AstraChatBody({
    required this.notifier,
    required this.voice,
    required this.language,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final scrollController = useScrollController();
    final listening = useState(false);

    useListenable(notifier);
    useListenable(voice);

    useEffect(() {
      if (notifier.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
      }
      return null;
    }, [notifier.messages.length]);

    void send() {
      final text = textController.text;
      textController.clear();
      notifier.sendUserMessage(text);
    }

    return Column(
      children: [
        if (notifier.error != null)
          Container(
            width: double.infinity,
            color: Palette.red_bg,
            padding: EdgeInsets.all(2.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(notifier.error!,
                      style: TextStyle(color: Palette.red, fontSize: 12.sp)),
                ),
                TextButton(
                  onPressed: () => notifier.init(),
                  child: Text(loc.t('astra_retry')),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            children: [
              for (final AstraMessage message in notifier.messages)
                AstraMessageBubble(
                  message: message,
                  onSpeak: message.role == AstraMessageRole.assistant &&
                          message.text.isNotEmpty
                      ? () =>
                          voice.speak(message.text, language: language.value)
                      : null,
                ),
              if (notifier.sending)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child:
                        SpinKitThreeBounce(color: Palette.primary, size: 3.w),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Row(
              children: [
                GestureDetector(
                  onLongPressStart: (_) async {
                    listening.value = true;
                    await voice.startListening(
                      language: language.value,
                      onResult: (text) {
                        listening.value = false;
                        if (text.trim().isNotEmpty) {
                          notifier.sendUserMessage(text);
                        }
                      },
                    );
                  },
                  onLongPressEnd: (_) async {
                    await voice.stopListening();
                    listening.value = false;
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        listening.value ? Palette.red : Palette.primary_bg,
                    child: Icon(
                      Icons.mic,
                      color: listening.value ? Palette.white : Palette.primary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: listening.value
                          ? loc.t('astra_listening')
                          : loc.t('astra_input_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => send(),
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: notifier.sending ? null : send,
                  icon: Icon(Icons.send, color: Palette.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
