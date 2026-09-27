import '../../../../model/v2/home_response.dart' show Doctor;

/// The five card kinds the backend contract defines for
/// `POST /astra/sessions/{id}/messages`. Phase 1 renders [tip], [doctor]
/// and [emergency]; [order] and [reminder] are modeled now (so the parser
/// and notifier are forward-compatible) but only get a generic placeholder
/// widget until Phase 2/3 build their real screens.
sealed class AstraCard {
  const AstraCard();
}

class TipCard extends AstraCard {
  final String title;
  final String body;

  const TipCard({required this.title, required this.body});
}

class DoctorRecommendationCard extends AstraCard {
  final Doctor doctor;
  final String? reason;

  const DoctorRecommendationCard({required this.doctor, this.reason});
}

class OrderCard extends AstraCard {
  final String orderId;
  final String summary;

  const OrderCard({required this.orderId, required this.summary});
}

class ReminderCard extends AstraCard {
  final String reminderId;
  final String medicineName;
  final String time;

  const ReminderCard({
    required this.reminderId,
    required this.medicineName,
    required this.time,
  });
}

/// Astra never diagnoses or prescribes - this card is the one hardcoded
/// exception where the app tells the patient to seek emergency care right
/// now, with a direct way to call 112. It is shown either by the client's
/// own RedFlagDetector (before any backend call) or by the backend's
/// triage/message response (`route: emergency` or a card of this kind).
class EmergencyCard extends AstraCard {
  final String message;
  final List<String> redFlags;

  const EmergencyCard({required this.message, required this.redFlags});
}
