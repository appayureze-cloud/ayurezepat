import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../data/wellness_goal_store.dart';
import '../domain/entities/wellness_goal.dart';

/// Simple, patient-set wellness goals (e.g. "Sleep 7+ hours"). Local only -
/// no backend tracks or scores these; marking one achieved is a self-report.
class WellnessGoalsScreen extends HookWidget {
  const WellnessGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = useState<List<WellnessGoal>>([]);
    final loading = useState(true);

    Future<void> reload() async {
      goals.value = await WellnessGoalStore.getAll();
      loading.value = false;
    }

    useEffect(() {
      reload();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, reload),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const Header_v2(title: 'Wellness goals'),
          Expanded(
            child: loading.value
                ? const Center(child: CircularProgressIndicator())
                : goals.value.isEmpty
                    ? const Center(
                        child: Text(
                          'No goals yet. Tap + to set one.',
                          style: TextStyle(color: AppColors.slateTextMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: goals.value.length,
                        itemBuilder: (context, index) {
                          final goal = goals.value[index];
                          return Dismissible(
                            key: ValueKey(goal.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.redAccent,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await WellnessGoalStore.remove(goal.id);
                              await reload();
                            },
                            child: CheckboxListTile(
                              value: goal.achieved,
                              onChanged: (_) async {
                                await WellnessGoalStore.toggleAchieved(goal.id);
                                await reload();
                              },
                              title: Text(
                                goal.title,
                                style: TextStyle(
                                  decoration: goal.achieved
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, Future<void> Function() reload) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New wellness goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Walk for 20 minutes daily',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                await WellnessGoalStore.add(title);
                await reload();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
