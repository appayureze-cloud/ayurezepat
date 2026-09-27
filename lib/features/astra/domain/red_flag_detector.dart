/// Client-side safety net, checked before any message is sent to Astra's
/// backend/LLM. If a message mentions a red-flag symptom, the UI must show
/// a hardcoded emergency card immediately - no network round trip, no LLM
/// call - per the Astra safety requirement. The backend's own
/// `POST /astra/cases/{id}/triage` also screens for red flags (it has more
/// context and better recall), but that check happens *after* a message
/// round trip, so it cannot be the only line of defense.
///
/// This is intentionally a blunt keyword match: false positives (showing
/// the emergency card when it wasn't truly an emergency) are an acceptable
/// cost; false negatives are not. Do not make this "smarter" (e.g. via an
/// LLM call) without keeping a keyword pass as a synchronous first gate.
enum RedFlag {
  chestPain,
  strokeSigns,
  breathingDifficulty,
  suicidalThoughts,
  heavyBleeding,
}

class RedFlagDetector {
  RedFlagDetector._();

  static const Map<RedFlag, List<String>> _keywords = {
    RedFlag.chestPain: [
      'chest pain',
      'chest pressure',
      'chest tightness',
      'pain in my chest',
      'crushing pain',
    ],
    RedFlag.strokeSigns: [
      'face drooping',
      'facial droop',
      'slurred speech',
      'can\'t speak',
      'cannot speak properly',
      'one side of my body',
      'sudden numbness',
      'sudden weakness',
      'sudden confusion',
    ],
    RedFlag.breathingDifficulty: [
      'can\'t breathe',
      'cannot breathe',
      'difficulty breathing',
      'shortness of breath',
      'gasping for air',
      'choking',
    ],
    RedFlag.suicidalThoughts: [
      'kill myself',
      'suicide',
      'suicidal',
      'end my life',
      'want to die',
      'harm myself',
    ],
    RedFlag.heavyBleeding: [
      'heavy bleeding',
      'won\'t stop bleeding',
      'bleeding heavily',
      'blood everywhere',
      'severe blood loss',
    ],
  };

  /// Returns every red flag whose keywords match [message], or an empty
  /// list if none matched. Matching is case-insensitive and
  /// punctuation-tolerant enough to catch the common phrasings above.
  static List<RedFlag> detect(String message) {
    final normalized = message.toLowerCase();
    final matches = <RedFlag>[];
    for (final entry in _keywords.entries) {
      if (entry.value.any(normalized.contains)) {
        matches.add(entry.key);
      }
    }
    return matches;
  }

  static bool hasRedFlag(String message) => detect(message).isNotEmpty;
}
