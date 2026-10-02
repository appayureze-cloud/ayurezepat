import 'entities/smart_order_draft.dart';

abstract class SmartOrderRepository {
  Future<SmartOrderDraft> getDraft(String id);

  /// Adds the draft's items to the cart via the existing `addtocart`
  /// endpoint and marks the draft bought. Returns once all items are
  /// queued - the patient still goes through the normal checkout flow.
  Future<void> markBought(String id);

  Future<void> markIgnored(String id);
}
