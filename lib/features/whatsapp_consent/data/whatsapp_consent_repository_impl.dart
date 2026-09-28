import 'package:dio/dio.dart';

import '../../../api/apis.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/entities/whatsapp_consent.dart';
import '../domain/whatsapp_consent_repository.dart';
import 'whatsapp_consent_dtos.dart';

class WhatsappConsentException implements Exception {
  final String message;
  WhatsappConsentException(this.message);

  @override
  String toString() => message;
}

/// Talks to the real consent endpoint. See docs/backend/whatsapp.md. Also
/// caches the last-known choice locally so the opt-in screen has something
/// to show immediately, offline-first, the same way CaseRepository caches
/// `activeCaseId`.
class WhatsappConsentRepositoryImpl implements WhatsappConsentRepository {
  final Dio dio;

  WhatsappConsentRepositoryImpl(this.dio);

  @override
  Future<WhatsappConsent> getConsent() async {
    final response = await dio.get('${Apis.baseUrl}consents/whatsapp');
    final parsed = WhatsappConsentResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw WhatsappConsentException(
          parsed.msg ?? 'Could not load WhatsApp consent status');
    }
    await _cacheLocally(parsed.data!.toEntity());
    return parsed.data!.toEntity();
  }

  @override
  Future<WhatsappConsent> setConsent({
    required bool optedIn,
    required String phone,
  }) async {
    final caseId = SharedPreferenceHelper.getString(Preferences.activeCaseId);
    final response = await dio.post(
      '${Apis.baseUrl}consents/whatsapp',
      data: WhatsappConsentRequest(
        optedIn: optedIn,
        phone: phone,
        caseId: (caseId != null && caseId.isNotEmpty) ? caseId : null,
      ).toJson(),
    );
    final parsed = WhatsappConsentResponse.fromJson(response.data);
    if (parsed.success != true || parsed.data == null) {
      throw WhatsappConsentException(
          parsed.msg ?? 'Could not save your WhatsApp preference');
    }
    await _cacheLocally(parsed.data!.toEntity());
    return parsed.data!.toEntity();
  }

  Future<void> _cacheLocally(WhatsappConsent consent) async {
    await SharedPreferenceHelper.setBoolean(
        Preferences.whatsappConsentOptedIn, consent.optedIn);
    if (consent.consentedAt != null) {
      await SharedPreferenceHelper.setString(
          Preferences.whatsappConsentAt, consent.consentedAt!);
    }
  }
}
