import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../data/wellness_log_store.dart';
import '../domain/entities/wellness_entry.dart';

/// Weekly summary over the last 7 logged days, computed entirely on-device
/// from WellnessLogStore - there's no backend trends endpoint to read from.
class WellnessTrendsScreen extends HookWidget {
  const WellnessTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = useState<List<WellnessEntry>>([]);
    final loading = useState(true);

    useEffect(() {
      Future(() async {
        entries.value = await WellnessLogStore.getAll();
        loading.value = false;
      });
      return null;
    }, const []);

    final last7 = useMemoized(() {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      return entries.value.where((e) {
        final d = DateTime.tryParse(e.dateKey);
        return d != null && !d.isBefore(cutoff);
      }).toList()
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    }, [entries.value]);

    double? average(Iterable<num?> values) {
      final present = values.whereType<num>().toList();
      if (present.isEmpty) return null;
      return present.reduce((a, b) => a + b) / present.length;
    }

    final avgSleep = average(last7.map((e) => e.sleepHours));
    final avgMovement = average(last7.map((e) => e.movementMinutes));
    final avgRelaxation = average(last7.map((e) => e.relaxationMinutes));
    final avgMood = average(last7.map((e) => e.mood));

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Weekly trends'),
          Expanded(
            child: loading.value
                ? const Center(child: CircularProgressIndicator())
                : last7.isEmpty
                    ? const Center(
                        child: Text(
                          'Log a few days to see trends here.',
                          style: TextStyle(color: AppColors.slateTextMuted),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'Last ${last7.length} day${last7.length == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _TrendCard(
                            label: 'Avg sleep',
                            value: avgSleep == null
                                ? '—'
                                : '${avgSleep.toStringAsFixed(1)}h',
                          ),
                          _TrendCard(
                            label: 'Avg movement',
                            value: avgMovement == null
                                ? '—'
                                : '${avgMovement.toStringAsFixed(0)} min',
                          ),
                          _TrendCard(
                            label: 'Avg relaxation',
                            value: avgRelaxation == null
                                ? '—'
                                : '${avgRelaxation.toStringAsFixed(0)} min',
                          ),
                          _TrendCard(
                            label: 'Avg mood',
                            value: avgMood == null
                                ? '—'
                                : '${avgMood.toStringAsFixed(1)} / 5',
                          ),
                          const SizedBox(height: 20),
                          Text('Sleep by day',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          _SleepBars(entries: last7),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String label;
  final String value;

  const _TrendCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamSurfaceLowest,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.sagePrimary)),
        ],
      ),
    );
  }
}

class _SleepBars extends StatelessWidget {
  final List<WellnessEntry> entries;

  const _SleepBars({required this.entries});

  @override
  Widget build(BuildContext context) {
    const maxHours = 12.0;
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final e in entries)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 90 *
                          ((e.sleepHours ?? 0).clamp(0, maxHours) / maxHours),
                      decoration: BoxDecoration(
                        color: AppColors.sagePrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.dateKey.substring(8),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
