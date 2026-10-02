/// Whether a prescribed medicine maps to a real, in-stock product in the
/// pharmacy's Shopify catalog. From the real, confirmed
/// `GET /api/v1/shopify/products/search/{medicine_name}` response (not a
/// guess - this shape was observed live during the Phase 4 audit). See
/// docs/backend/astra.md.
class MedicineAvailability {
  final String medicineName;
  final String? shopifyVariantId;
  final String? shopifyProductTitle;
  final bool isAvailable;
  final List<String> suggestedAlternatives;

  const MedicineAvailability({
    required this.medicineName,
    this.shopifyVariantId,
    this.shopifyProductTitle,
    required this.isAvailable,
    this.suggestedAlternatives = const [],
  });
}
