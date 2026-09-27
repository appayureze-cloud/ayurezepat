/// `GET /astra/medicines/{id}/info`. Not wired into any Phase 1 screen -
/// used by the medicine-info lookup planned for Phase 3's reminders.
class MedicineInfo {
  final String medicineId;
  final String name;
  final String description;
  final List<String> commonSideEffects;

  const MedicineInfo({
    required this.medicineId,
    required this.name,
    required this.description,
    this.commonSideEffects = const [],
  });
}
