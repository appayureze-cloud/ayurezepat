import '../../../../model/v2/home_response.dart' show Doctor;
import 'astra_card.dart' show TipCard;

/// `GET /astra/cases/{id}/recommendations` returns either self-care tips
/// (mild triage route) or doctors to book (everything else) - never both.
class AstraRecommendations {
  final List<TipCard> tips;
  final List<Doctor> doctors;

  const AstraRecommendations({this.tips = const [], this.doctors = const []});
}
