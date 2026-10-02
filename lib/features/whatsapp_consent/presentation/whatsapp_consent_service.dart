import 'package:dio/dio.dart';

import '../../../const/env.dart';
import '../data/mock_whatsapp_consent_repository.dart';
import '../data/whatsapp_consent_repository_impl.dart';
import '../domain/entities/whatsapp_consent.dart';
import '../domain/whatsapp_consent_repository.dart';

/// Resolves the real vs mock WhatsappConsentRepository, the same pattern as
/// CaseService/PaymentService.
class WhatsappConsentService {
  final WhatsappConsentRepository _repository;

  WhatsappConsentService(this._repository);

  factory WhatsappConsentService.withDio(Dio dio) => WhatsappConsentService(
        Env.useMockWhatsappConsent
            ? MockWhatsappConsentRepository()
            : WhatsappConsentRepositoryImpl(dio),
      );

  Future<WhatsappConsent> getConsent() => _repository.getConsent();

  Future<WhatsappConsent> setConsent({
    required bool optedIn,
    required String phone,
  }) =>
      _repository.setConsent(optedIn: optedIn, phone: phone);
}
