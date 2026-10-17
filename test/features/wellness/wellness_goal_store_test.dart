import 'package:doctro_patient/features/wellness/data/wellness_goal_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WellnessGoalStore', () {
    test('add then getAll returns the new goal, unachieved by default',
        () async {
      await WellnessGoalStore.add('Sleep 7+ hours');

      final goals = await WellnessGoalStore.getAll();
      expect(goals, hasLength(1));
      expect(goals.first.title, 'Sleep 7+ hours');
      expect(goals.first.achieved, isFalse);
    });

    test('toggleAchieved flips only the targeted goal', () async {
      await WellnessGoalStore.add('Walk daily');
      await WellnessGoalStore.add('Drink more water');
      final goals = await WellnessGoalStore.getAll();
      final walkGoalId = goals.firstWhere((g) => g.title == 'Walk daily').id;

      await WellnessGoalStore.toggleAchieved(walkGoalId);

      final updated = await WellnessGoalStore.getAll();
      expect(updated.firstWhere((g) => g.id == walkGoalId).achieved, isTrue);
      expect(
        updated.firstWhere((g) => g.title == 'Drink more water').achieved,
        isFalse,
      );
    });

    test('remove deletes the goal', () async {
      await WellnessGoalStore.add('Temporary goal');
      final goals = await WellnessGoalStore.getAll();
      final id = goals.first.id;

      await WellnessGoalStore.remove(id);

      expect(await WellnessGoalStore.getAll(), isEmpty);
    });
  });
}
