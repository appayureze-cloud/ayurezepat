import 'entities/case.dart';

/// The one place bookings/orders/therapy look up "which case is this for".
abstract class CaseRepository {
  /// Returns the patient's current active case, creating one if none
  /// exists or the cached one has been resolved/closed.
  Future<Case> ensureActiveCase();

  Future<Case> getCase(String id);

  Future<Case> createCase();
}
