import '../../../appointments/domain/entities/doctor_summary.dart';
import 'astra_card.dart' show TipCard;

/// `GET /astra/cases/{id}/recommendations` returns either self-care tips
/// (mild triage route) or doctors to book (everything else) - never both.
class AstraRecommendations {
  final List<TipCard> tips;
  final List<DoctorSummary> doctors;

  const AstraRecommendations({this.tips = const [], this.doctors = const []});
}
