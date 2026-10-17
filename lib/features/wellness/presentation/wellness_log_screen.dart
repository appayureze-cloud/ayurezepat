import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../domain/entities/wellness_entry.dart';
import 'ayurveda_education_screen.dart';
import 'wellness_goals_screen.dart';
import 'wellness_log_notifier.dart';
import 'wellness_trends_screen.dart';

const _moodLabels = ['', 'Low', 'Rough', 'Okay', 'Good', 'Great'];

/// Routine tracking + a lightweight symptom diary, one entry per day.
/// Entirely optional and entirely local - there's no backend endpoint for
/// this, so nothing here is sent anywhere.
class WellnessLogScreen extends HookWidget {
  const WellnessLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = useMemoized(() => WellnessLogNotifier());
    useEffect(() {
      notifier.load();
      notifier.addListener(() {});
      return null;
    }, const []);

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.creamSurface,
          body: Column(
            children: [
              Header_v2(
                title: 'Wellness log',
                actions: [
                  IconButton(
                    tooltip: 'Goals',
                    icon: const Icon(Icons.flag_outlined,
                        color: AppColors.sagePrimary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WellnessGoalsScreen()),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ayurveda basics',
                    icon: const Icon(Icons.menu_book_outlined,
                        color: AppColors.sagePrimary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AyurvedaEducationScreen()),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Trends',
                    icon: const Icon(Icons.show_chart,
                        color: AppColors.sagePrimary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WellnessTrendsScreen()),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: notifier.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _TodayCard(
                            entry: notifier.today,
                            onTap: () => _openEditSheet(context, notifier),
                          ),
                          const SizedBox(height: 20),
                          Text('History',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          if (notifier.entries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No entries yet. Log today to get started.',
                                  style: TextStyle(
                                      color: AppColors.slateTextMuted),
                                ),
                              ),
                            )
                          else
                            for (final entry in notifier.entries)
                              _HistoryTile(entry: entry),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditSheet(BuildContext context, WellnessLogNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EntryEditSheet(notifier: notifier),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final WellnessEntry? entry;
  final VoidCallback onTap;

  const _TodayCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sagePrimarySubtle,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (entry == null)
            const Text("You haven't logged today yet.",
                style: TextStyle(color: AppColors.slateTextSecondary))
          else
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (entry!.sleepHours != null)
                  _StatChip(label: 'Sleep', value: '${entry!.sleepHours}h'),
                if (entry!.movementMinutes != null)
                  _StatChip(
                      label: 'Movement', value: '${entry!.movementMinutes}m'),
                if (entry!.relaxationMinutes != null)
                  _StatChip(
                      label: 'Relaxation',
                      value: '${entry!.relaxationMinutes}m'),
                if (entry!.mood != null)
                  _StatChip(label: 'Mood', value: _moodLabels[entry!.mood!]),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              child: Text(entry == null ? 'Log today' : 'Edit today'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLowest,
        borderRadius: AppRadius.roundedSm,
      ),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12)),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WellnessEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (entry.sleepHours != null) 'Sleep ${entry.sleepHours}h',
      if (entry.movementMinutes != null) 'Movement ${entry.movementMinutes}m',
      if (entry.relaxationMinutes != null)
        'Relaxation ${entry.relaxationMinutes}m',
      if (entry.mood != null) 'Mood ${_moodLabels[entry.mood!]}',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(entry.dateKey,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        [
          if (parts.isEmpty) 'No metrics logged' else parts.join(' · '),
          if (entry.note != null && entry.note!.isNotEmpty) entry.note!
        ].join('\n'),
      ),
      isThreeLine: entry.note != null && entry.note!.isNotEmpty,
    );
  }
}

class _EntryEditSheet extends HookWidget {
  final WellnessLogNotifier notifier;

  const _EntryEditSheet({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final existing = notifier.today;
    final sleep = useState(existing?.sleepHours ?? 7.0);
    final movement = useState(existing?.movementMinutes ?? 0);
    final relaxation = useState(existing?.relaxationMinutes ?? 0);
    final mood = useState(existing?.mood ?? 3);
    final noteController = useTextEditingController(text: existing?.note ?? '');

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log today', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Sleep: ${sleep.value.toStringAsFixed(1)}h'),
          Slider(
            value: sleep.value,
            min: 0,
            max: 12,
            divisions: 24,
            onChanged: (v) => sleep.value = v,
          ),
          Text('Movement: ${movement.value} min'),
          Slider(
            value: movement.value.toDouble(),
            min: 0,
            max: 120,
            divisions: 24,
            onChanged: (v) => movement.value = v.round(),
          ),
          Text('Relaxation: ${relaxation.value} min'),
          Slider(
            value: relaxation.value.toDouble(),
            min: 0,
            max: 120,
            divisions: 24,
            onChanged: (v) => relaxation.value = v.round(),
          ),
          const SizedBox(height: 4),
          const Text('Mood'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 1; i <= 5; i++)
                ChoiceChip(
                  label: Text(_moodLabels[i]),
                  selected: mood.value == i,
                  onSelected: (_) => mood.value = i,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Anything to note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await notifier.saveToday(
                  sleepHours: sleep.value,
                  movementMinutes: movement.value,
                  relaxationMinutes: relaxation.value,
                  mood: mood.value,
                  note: noteController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
