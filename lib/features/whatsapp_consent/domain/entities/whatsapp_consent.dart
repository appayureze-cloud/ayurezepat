/// Whether the patient has opted in to receive treatment/order updates via
/// WhatsApp. The app never talks to the WhatsApp Business Solution Provider
/// directly - it only records this choice with our backend, which relays it
/// to the BSP. See docs/backend/whatsapp.md.
class WhatsappConsent {
  final bool optedIn;
  final String? consentedAt;

  const WhatsappConsent({required this.optedIn, this.consentedAt});
}
