import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/case.dart';

/// A purely local record of this device's past companion journeys.
///
/// There's no backend endpoint that lists a patient's past cases - Astra
/// only exposes the single active one (`ensureActiveCase`/`getCase`), so
/// a "Companion Chat History" screen backed by the server would mean
/// fabricating conversations. This instead keeps a real, on-device
/// record: whenever a case is actually closed from this app (see
/// CaseSummaryScreen.resolve()), a snapshot is appended here. It won't
/// show history from another device, but it never shows anything that
/// didn't really happen on this one.
class CaseHistoryStore {
  CaseHistoryStore._();

  static const _key = 'companion_case_history';

  static Future<void> recordClosed(Case closedCase) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    // Avoid duplicate entries if the same case is somehow closed twice.
    final withoutDuplicate = existing.where((raw) {
      try {
        return (jsonDecode(raw) as Map<String, dynamic>)['id'] != closedCase.id;
      } catch (_) {
        return true;
      }
    }).toList();
    withoutDuplicate.add(jsonEncode({
      ...closedCase.toJson(),
      'closed_at': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList(_key, withoutDuplicate);
  }

  static Future<List<(Case, DateTime?)>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entries = <(Case, DateTime?)>[];
    for (final item in raw) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        final closedAtRaw = json['closed_at'] as String?;
        entries.add((
          Case.fromJson(json),
          closedAtRaw != null ? DateTime.tryParse(closedAtRaw) : null,
        ));
      } catch (_) {
        // Skip malformed entries rather than failing the whole history.
      }
    }
    entries.sort((a, b) {
      if (a.$2 == null || b.$2 == null) return 0;
      return b.$2!.compareTo(a.$2!);
    });
    return entries;
  }
}
