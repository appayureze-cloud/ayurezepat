import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'voice_controller.dart' show AstraVoiceLanguage;

/// English/Hindi strings scoped to the Astra screen only.
///
/// The app's own localization framework (lib/localization/language_localization.dart)
/// is dead code - its delegate is commented out in main.dart and no screen
/// in the app is wired to it. Resurrecting app-wide i18n is a much larger,
/// separate effort ("refactor old screens only where you touch them"), so
/// Astra ships its own minimal EN/HI string table
/// (lib/localization/languages/astra_en.json, astra_hi.json) instead of
/// pretending to plug into a framework nothing else uses.
class AstraLocalization {
  final Map<String, String> _values;

  AstraLocalization._(this._values);

  /// Falls back to returning the key itself for every lookup - used before
  /// the real strings finish loading, and in tests that don't need real
  /// translations.
  factory AstraLocalization.empty() => AstraLocalization._(const {});

  static Future<AstraLocalization> load(AstraVoiceLanguage language) async {
    final code = language == AstraVoiceLanguage.hindi ? 'hi' : 'en';
    final jsonStr = await rootBundle
        .loadString('lib/localization/languages/astra_$code.json');
    final map = Map<String, dynamic>.from(jsonDecode(jsonStr));
    return AstraLocalization._(map.map((k, v) => MapEntry(k, v.toString())));
  }

  String t(String key) => _values[key] ?? key;
}
