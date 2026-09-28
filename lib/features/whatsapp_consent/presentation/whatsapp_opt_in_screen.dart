import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../v2/ui/widgets/header.dart';
import 'whatsapp_consent_service.dart';

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
      body: Column(
        children: [
          const Header_v2(title: 'WhatsApp Updates'),
          Expanded(
            child: loading.value
                ? Center(
                    child:
                        SpinKitFadingCircle(color: Palette.primary, size: 6.h),
                  )
                : Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: optedIn.value,
                          onChanged:
                              saving.value || phone.isEmpty ? null : toggle,
                          activeColor: Palette.primary,
                          title: Text(
                            'Get updates on WhatsApp',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          subtitle: Text(
                            phone.isNotEmpty
                                ? 'Sent to $phone'
                                : 'Add a phone number in Edit Profile first',
                            style: TextStyle(
                                fontSize: 12.sp, color: Palette.dark_grey),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'We\'ll send order status, dose reminders and '
                          'appointment confirmations to your WhatsApp number. '
                          'You can turn this off at any time. Astra will '
                          'never send diagnoses or prescriptions over '
                          'WhatsApp.',
                          style: TextStyle(
                              fontSize: 12.sp, color: Palette.dark_grey1),
                        ),
                        if (consentedAt.value != null) ...[
                          SizedBox(height: 1.h),
                          Text(
                            'Last updated: ${consentedAt.value}',
                            style: TextStyle(
                                fontSize: 11.sp, color: Palette.dark_grey),
                          ),
                        ],
                        if (error.value != null) ...[
                          SizedBox(height: 2.h),
                          Text(error.value!,
                              style: TextStyle(color: Palette.red)),
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
