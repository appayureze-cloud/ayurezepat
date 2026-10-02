enum SmartOrderDraftStatus { pending, bought, ignored }

class SmartOrderDraftItem {
  final int? productId;
  final int? variantId;
  final String name;
  final int quantity;
  final double price;

  const SmartOrderDraftItem({
    this.productId,
    this.variantId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

/// Auto-created when a prescription is issued (see
/// docs/backend/smart-orders.md), one per prescription. The patient is
/// prompted to buy or ignore it; if ignored, Astra re-nudges after 24h
/// (SmartOrderDraftService._scheduleReprompt).
class SmartOrderDraft {
  final String id;
  final String caseId;
  final String prescriptionId;
  final List<SmartOrderDraftItem> items;
  final SmartOrderDraftStatus status;

  const SmartOrderDraft({
    required this.id,
    required this.caseId,
    required this.prescriptionId,
    required this.items,
    required this.status,
  });

  double get total => items.fold(0, (sum, i) => sum + i.price * i.quantity);
}
