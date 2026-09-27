import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/astra/data/mock_astra_repository.dart';
import 'package:doctro_patient/features/astra/presentation/astra_chat_notifier.dart';
import 'package:doctro_patient/features/astra/presentation/astra_chat_screen.dart';
import 'package:doctro_patient/features/astra/presentation/astra_localization.dart';
import 'package:doctro_patient/features/astra/presentation/voice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

// Note on `tester.runAsync`: MockAstraRepository uses real `Future.delayed`
// calls to simulate network latency. `testWidgets` runs on a fake clock
// where such timers never fire on their own - only `tester.runAsync` (which
// steps outside the fake zone onto the real event loop) lets them resolve.
// Without it these tests hang forever rather than failing, which is exactly
// what happened while writing this file - see git history for the debug
// trail if this trips someone else up.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferenceHelper.init();
  });

  // Every widget in the Astra screen uses sizer's .w/.h/.sp extensions,
  // which need a Sizer ancestor (normally provided once at the app root in
  // main.dart) to be initialized.
  Widget wrap(Widget child) => Sizer(
        builder: (context, orientation, deviceType) =>
            MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('shows the greeting after the session initializes',
      (tester) async {
    final notifier =
        AstraChatNotifier(MockAstraRepository(), AstraLocalization.empty());
    await tester.runAsync(() => notifier.init());

    await tester.pumpWidget(wrap(AstraChatBody(
      notifier: notifier,
      voice: VoiceController(),
      language: ValueNotifier(AstraVoiceLanguage.english),
      loc: AstraLocalization.empty(),
    )));
    await tester.pump();

    expect(find.text(notifier.messages.first.text), findsOneWidget);
  });

  testWidgets(
      'sending a red-flag message renders the emergency card and a call button',
      (tester) async {
    final notifier =
        AstraChatNotifier(MockAstraRepository(), AstraLocalization.empty());
    await tester.runAsync(() => notifier.init());

    await tester.pumpWidget(wrap(AstraChatBody(
      notifier: notifier,
      voice: VoiceController(),
      language: ValueNotifier(AstraVoiceLanguage.english),
      loc: AstraLocalization.empty(),
    )));

    // The red-flag path is fully synchronous (no repository call), so a
    // plain tap + pump is enough here.
    await tester.enterText(find.byType(TextField), 'I have chest pain');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.text('This may be a medical emergency'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Call 112 now'), findsOneWidget);
  });

  testWidgets('sending an ordinary message renders a streamed reply',
      (tester) async {
    final notifier =
        AstraChatNotifier(MockAstraRepository(), AstraLocalization.empty());
    await tester.runAsync(() => notifier.init());

    await tester.pumpWidget(wrap(AstraChatBody(
      notifier: notifier,
      voice: VoiceController(),
      language: ValueNotifier(AstraVoiceLanguage.english),
      loc: AstraLocalization.empty(),
    )));

    await tester.enterText(find.byType(TextField), 'I have a mild cold');
    // The send button kicks off notifier.sendUserMessage without awaiting
    // it, so the tap itself - and the real delays it triggers inside the
    // mock repository's stream - both need to run inside runAsync.
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.send));
      // The mock repository streams its reply back word by word (~15ms
      // each) after an initial 200ms delay - give it enough real time to
      // fully drain before asserting on the final state.
      await Future.delayed(const Duration(seconds: 2));
    });
    // Not pumpAndSettle: the focused TextField's cursor blinks forever and
    // never lets it settle. A couple of plain pumps is enough to flush the
    // rebuild(s) notifyListeners already scheduled during runAsync.
    await tester.pump();
    await tester.pump();

    expect(notifier.messages.last.text, isNotEmpty);
    expect(find.text('Rest and fluids'), findsOneWidget);
  });
}
