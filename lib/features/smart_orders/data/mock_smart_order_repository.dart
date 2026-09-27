import '../domain/entities/smart_order_draft.dart';
import '../domain/smart_order_repository.dart';

class MockSmartOrderRepository implements SmartOrderRepository {
  final Map<String, SmartOrderDraft> _drafts = {};

  SmartOrderDraft _seed(String id) => SmartOrderDraft(
        id: id,
        caseId: 'mock_case',
        prescriptionId: 'mock_prescription',
        status: SmartOrderDraftStatus.pending,
        items: const [
          SmartOrderDraftItem(
            productId: 1,
            variantId: 1,
            name: 'Paracetamol 500mg',
            quantity: 1,
            price: 40,
          ),
          SmartOrderDraftItem(
            productId: 2,
            variantId: 2,
            name: 'Ashwagandha Churna',
            quantity: 1,
            price: 220,
          ),
        ],
      );

  @override
  Future<SmartOrderDraft> getDraft(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _drafts[id] ??= _seed(id);
  }

  @override
  Future<void> markBought(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final draft = await getDraft(id);
    _drafts[id] = SmartOrderDraft(
      id: draft.id,
      caseId: draft.caseId,
      prescriptionId: draft.prescriptionId,
      items: draft.items,
      status: SmartOrderDraftStatus.bought,
    );
  }

  @override
  Future<void> markIgnored(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final draft = await getDraft(id);
    _drafts[id] = SmartOrderDraft(
      id: draft.id,
      caseId: draft.caseId,
      prescriptionId: draft.prescriptionId,
      items: draft.items,
      status: SmartOrderDraftStatus.ignored,
    );
  }
}
