import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/wellness_goal.dart';

class WellnessGoalStore {
  WellnessGoalStore._();

  static const _key = 'wellness_goals';

  static Future<List<WellnessGoal>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final goals = <WellnessGoal>[];
    for (final item in raw) {
      try {
        goals.add(WellnessGoal.fromJson(jsonDecode(item)));
      } catch (_) {
        // Skip malformed entries.
      }
    }
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  static Future<void> add(String title) async {
    final goals = await getAll();
    goals.insert(
      0,
      WellnessGoal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    await _save(goals);
  }

  static Future<void> toggleAchieved(String id) async {
    final goals = await getAll();
    final updated = goals
        .map((g) => g.id == id ? g.copyWith(achieved: !g.achieved) : g)
        .toList();
    await _save(updated);
  }

  static Future<void> remove(String id) async {
    final goals = await getAll();
    goals.removeWhere((g) => g.id == id);
    await _save(goals);
  }

  static Future<void> _save(List<WellnessGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, goals.map((g) => jsonEncode(g.toJson())).toList());
  }
}
