/// `POST /astra/cases/{id}/checkins`. Not wired into any Phase 1 screen -
/// the daily check-in UI is Phase 3.
class CheckinResult {
  final String nextAction;
  final bool escalate;

  const CheckinResult({required this.nextAction, required this.escalate});
}
