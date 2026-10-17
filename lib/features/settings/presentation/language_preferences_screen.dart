import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../astra/presentation/voice_controller.dart';

/// Matches the Stitch "Language & App Preferences" screen
/// (ayureze_language_app_preferences/code.html): English/Hindi radio
/// rows - the only two languages Astra's localization actually supports
/// (lib/features/astra/presentation/astra_localization.dart). Persists
/// as the default Astra opens with; still switchable per-conversation
/// from the chat's own EN/हिन्दी toggle.
class LanguagePreferencesScreen extends HookWidget {
  const LanguagePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stored = SharedPreferenceHelper.getString(Preferences.app_language);
    final selected = useState(
      stored == 'hi' ? AstraVoiceLanguage.hindi : AstraVoiceLanguage.english,
    );

    void select(AstraVoiceLanguage language) {
      selected.value = language;
      SharedPreferenceHelper.setString(Preferences.app_language,
          language == AstraVoiceLanguage.hindi ? 'hi' : 'en');
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Language & Preferences'),
          const SizedBox(height: 8),
          RadioListTile<AstraVoiceLanguage>(
            title: const Text('English'),
            value: AstraVoiceLanguage.english,
            groupValue: selected.value,
            activeColor: AppColors.sagePrimary,
            onChanged: (v) => select(v!),
          ),
          RadioListTile<AstraVoiceLanguage>(
            title: const Text('हिन्दी (Hindi)'),
            value: AstraVoiceLanguage.hindi,
            groupValue: selected.value,
            activeColor: AppColors.sagePrimary,
            onChanged: (v) => select(v!),
          ),
        ],
      ),
    );
  }
}
