import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../data/case_history_store.dart';
import '../domain/entities/case.dart';

String _outcomeLabel(CaseStatus status) => switch (status) {
      CaseStatus.resolved => 'Resolved',
      CaseStatus.closed => 'Closed',
      _ => 'Ended',
    };

/// Matches the Stitch "Companion Chat History" screen
/// (ayureze_companion_chat_history/code.html): a list of past
/// conversations. Astra's API only ever exposes the single active case
/// (no endpoint lists past ones), so this reads CaseHistoryStore - a
/// local, on-device record of journeys this app itself closed - instead
/// of inventing conversations that never happened.
class CompanionChatHistoryScreen extends HookWidget {
  const CompanionChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = useState<List<(Case, DateTime?)>>([]);
    final loading = useState(true);

    useEffect(() {
      Future(() async {
        history.value = await CaseHistoryStore.getHistory();
        loading.value = false;
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Companion History'),
          if (loading.value)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sagePrimary),
              ),
            )
          else if (history.value.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.history,
                          size: 56, color: AppColors.slateTextMuted),
                      SizedBox(height: 14),
                      Text('No past conversations yet',
                          style: TextStyle(color: AppColors.slateTextMuted)),
                      SizedBox(height: 6),
                      Text(
                        'Journeys you close with Astra will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.slateTextMuted),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.value.length,
                itemBuilder: (context, index) {
                  final (caseItem, closedAt) = history.value[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.sagePrimarySubtle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology_outlined,
                              size: 18, color: AppColors.sagePrimary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (caseItem.specialty ?? '').isNotEmpty
                                    ? caseItem.specialty!
                                    : 'Companion conversation',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (closedAt != null)
                                Text(
                                  DateFormat('d MMM yyyy, h:mm a')
                                      .format(closedAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sagePrimarySubtle,
                            borderRadius: AppRadius.roundedPill,
                          ),
                          child: Text(
                            _outcomeLabel(caseItem.status),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sagePrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
