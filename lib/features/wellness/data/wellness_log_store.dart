import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/wellness_entry.dart';

/// Local store for [WellnessEntry] rows, one per calendar day. Follows the
/// same pattern as CaseHistoryStore: a JSON string list under a single
/// SharedPreferences key, since there's no backend surface for routine
/// tracking or a symptom diary to sync against.
class WellnessLogStore {
  WellnessLogStore._();

  static const _key = 'wellness_log_entries';

  /// Inserts or replaces the entry for [entry.dateKey].
  static Future<void> upsert(WellnessEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    final withoutSameDay = existing.where((raw) {
      try {
        return (jsonDecode(raw) as Map<String, dynamic>)['date_key'] !=
            entry.dateKey;
      } catch (_) {
        return true;
      }
    }).toList();
    withoutSameDay.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, withoutSameDay);
  }

  /// All entries, most recent day first.
  static Future<List<WellnessEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final entries = <WellnessEntry>[];
    for (final item in raw) {
      try {
        entries.add(WellnessEntry.fromJson(jsonDecode(item)));
      } catch (_) {
        // Skip malformed entries rather than failing the whole log.
      }
    }
    entries.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return entries;
  }

  static Future<WellnessEntry?> getForDate(DateTime date) async {
    final key = WellnessEntry.dateKeyFor(date);
    final all = await getAll();
    for (final entry in all) {
      if (entry.dateKey == key) return entry;
    }
    return null;
  }
}
