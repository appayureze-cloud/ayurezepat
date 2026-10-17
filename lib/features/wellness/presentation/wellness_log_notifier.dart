import 'package:flutter/foundation.dart';

import '../data/wellness_log_store.dart';
import '../domain/entities/wellness_entry.dart';

/// Loads and upserts [WellnessEntry] rows for the wellness log screen.
class WellnessLogNotifier extends ChangeNotifier {
  List<WellnessEntry> entries = [];
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    entries = await WellnessLogStore.getAll();
    loading = false;
    notifyListeners();
  }

  WellnessEntry? get today {
    final key = WellnessEntry.dateKeyFor(DateTime.now());
    for (final e in entries) {
      if (e.dateKey == key) return e;
    }
    return null;
  }

  Future<void> saveToday({
    double? sleepHours,
    int? movementMinutes,
    int? relaxationMinutes,
    int? mood,
    String? note,
  }) async {
    final key = WellnessEntry.dateKeyFor(DateTime.now());
    final existing = today;
    final updated = (existing ??
            WellnessEntry(
                dateKey: key, updatedAt: DateTime.now().toIso8601String()))
        .copyWith(
      sleepHours: sleepHours,
      movementMinutes: movementMinutes,
      relaxationMinutes: relaxationMinutes,
      mood: mood,
      note: note,
    );
    await WellnessLogStore.upsert(updated);
    await load();
  }
}
