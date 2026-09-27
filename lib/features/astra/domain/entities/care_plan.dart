/// `GET /astra/cases/{id}/plan`. Not rendered by any Phase 1 screen yet -
/// modeled now so the repository interface matches the full contract; the
/// dose-reminder and check-in screens land in Phase 3.
class CarePlan {
  final List<PlannedMedicine> medicines;
  final List<String> checkIns;

  const CarePlan({this.medicines = const [], this.checkIns = const []});
}

class PlannedMedicine {
  final String medicineId;
  final String name;
  final List<String> doseTimes;

  const PlannedMedicine({
    required this.medicineId,
    required this.name,
    this.doseTimes = const [],
  });
}
