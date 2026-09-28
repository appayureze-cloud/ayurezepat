import 'package:flutter/foundation.dart';

import '../domain/astra_repository.dart';
import '../domain/entities/checkin_result.dart';

enum DailyCheckinStatus { idle, submitting, done, error }

/// Drives the daily check-in card: pick a symptom score (1 = fine, 5 = much
/// worse), submit it via `POST /astra/cases/{id}/checkins`, and surface
/// whether the backend wants the patient to keep following the plan or
/// escalate to Astra/a doctor.
class DailyCheckinNotifier extends ChangeNotifier {
  final AstraRepository repository;
  final String caseId;

  DailyCheckinNotifier(this.repository, this.caseId);

  int symptomScore = 1;
  DailyCheckinStatus status = DailyCheckinStatus.idle;
  CheckinResult? result;
  String? error;

  void setScore(int score) {
    symptomScore = score;
    notifyListeners();
  }

  Future<void> submit() async {
    status = DailyCheckinStatus.submitting;
    error = null;
    notifyListeners();
    try {
      result = await repository.checkin(caseId, symptomScore: symptomScore);
      status = DailyCheckinStatus.done;
    } catch (e) {
      error = 'Could not submit your check-in. Please try again.';
      status = DailyCheckinStatus.error;
    }
    notifyListeners();
  }
}
