import 'package:doctro_patient/features/smart_orders/data/mock_smart_order_repository.dart';
import 'package:doctro_patient/features/smart_orders/domain/entities/smart_order_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockSmartOrderRepository', () {
    test('getDraft returns a pending draft with items', () async {
      final repo = MockSmartOrderRepository();
      final draft = await repo.getDraft('d1');

      expect(draft.id, 'd1');
      expect(draft.status, SmartOrderDraftStatus.pending);
      expect(draft.items, isNotEmpty);
      expect(draft.total, greaterThan(0));
    });

    test('markBought updates the draft status', () async {
      final repo = MockSmartOrderRepository();
      await repo.getDraft('d1');
      await repo.markBought('d1');

      final draft = await repo.getDraft('d1');
      expect(draft.status, SmartOrderDraftStatus.bought);
    });

    test('markIgnored updates the draft status', () async {
      final repo = MockSmartOrderRepository();
      await repo.getDraft('d1');
      await repo.markIgnored('d1');

      final draft = await repo.getDraft('d1');
      expect(draft.status, SmartOrderDraftStatus.ignored);
    });
  });
}
