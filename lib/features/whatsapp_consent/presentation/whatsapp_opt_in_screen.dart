import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import 'whatsapp_consent_service.dart';

/// Matches the Stitch "WhatsApp Consent" screen
/// (ayureze_whatsapp_consent/code.html): a single calm card explaining
/// what gets sent, a toggle, and a short privacy note.
///
/// Lets the patient opt in/out of WhatsApp updates (order status, dose
/// reminders, appointment confirmations). The app never messages the
/// WhatsApp BSP directly - this only records the choice with our backend
/// (docs/backend/whatsapp.md), which relays it to the BSP.
class WhatsappOptInScreen extends HookWidget {
  const WhatsappOptInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final saving = useState(false);
    final optedIn = useState(false);
    final consentedAt = useState<String?>(null);
    final error = useState<String?>(null);
    final service = useState<WhatsappConsentService?>(null);
    final phone = SharedPreferenceHelper.getString(Preferences.phone) ?? '';

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final dio = await RetroApi().dioData(context);
        service.value = WhatsappConsentService.withDio(dio);
        final consent = await service.value!.getConsent();
        optedIn.value = consent.optedIn;
        consentedAt.value = consent.consentedAt;
      } catch (e) {
        error.value = 'Could not load your WhatsApp preference.';
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> toggle(bool value) async {
      if (service.value == null || saving.value || phone.isEmpty) return;
      saving.value = true;
      error.value = null;
      try {
        final consent =
            await service.value!.setConsent(optedIn: value, phone: phone);
        optedIn.value = consent.optedIn;
        consentedAt.value = consent.consentedAt;
        Fluttertoast.showToast(
          msg: value
              ? 'You\'ll now get updates on WhatsApp'
              : 'You\'ve opted out of WhatsApp updates',
        );
      } catch (e) {
        error.value = 'Could not save your preference. Please try again.';
      } finally {
        saving.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'WhatsApp Updates'),
          Expanded(
            child: loading.value
                ? const Center(
                    child: SpinKitFadingCircle(
                        color: AppColors.sagePrimary, size: 36),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.creamSurfaceLowest,
                            border: Border.all(color: AppColors.slateBorder),
                            borderRadius: AppRadius.roundedLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.sagePrimarySubtle,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chat_outlined,
                                        color: AppColors.sagePrimary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Get updates on WhatsApp',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall),
                                        Text(
                                          phone.isNotEmpty
                                              ? 'Sent to $phone'
                                              : 'Add a phone number in Edit Profile first',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: optedIn.value,
                                    onChanged: saving.value || phone.isEmpty
                                        ? null
                                        : toggle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We\'ll send order status, dose reminders and '
                          'appointment confirmations to your WhatsApp number. '
                          'You can turn this off at any time. Astra will '
                          'never send diagnoses or prescriptions over '
                          'WhatsApp.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (consentedAt.value != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Last updated: ${consentedAt.value}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.slateTextMuted),
                          ),
                        ],
                        if (error.value != null) ...[
                          const SizedBox(height: 14),
                          Text(error.value!,
                              style:
                                  const TextStyle(color: AppColors.clayAlert)),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
