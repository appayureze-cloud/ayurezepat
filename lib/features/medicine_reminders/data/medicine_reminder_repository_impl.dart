import '../../../v2/utils/logger.dart';
import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/medicine_reminder_repository.dart';
import 'medicine_reminder_dtos.dart';

/// Talks to the real Supabase-backed medicine reminders API on the Astra
/// gateway. Unlike the companion chat API, these routes are marked
/// `security: none` in the published OpenAPI spec (no bearer token
/// required) - still routed through [AstraGatewayClient] for a consistent
/// base URL/timeout setup, the token it attaches is simply unused server
/// side. See docs/backend/astra.md.
class MedicineReminderRepositoryImpl implements MedicineReminderRepository {
  final AstraGatewayClient _gateway;

  MedicineReminderRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<String?> createReminder({
    required String patientId,
    String? patientName,
    String? patientPhone,
    required String medicineName,
    required String dosage,
    required String frequency,
    required List<String> times,
    required String startDate,
    required String endDate,
    String? instructions,
    bool enableWhatsapp = true,
  }) async {
    final dio = await _gateway.dio();
    final response = await dio.post(
      AstraGatewayApis.remindersCreate,
      data: CreateReminderRequest(
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        medicineName: medicineName,
        dosage: dosage,
        frequency: frequency,
        times: times,
        startDate: startDate,
        endDate: endDate,
        instructions: instructions,
        enableWhatsapp: enableWhatsapp,
      ).toJson(),
    );
    return _extractReminderId(response.data);
  }

  @override
  Future<void> logAdherence({
    required String reminderId,
    required bool taken,
  }) async {
    final dio = await _gateway.dio();
    await dio.post(
      AstraGatewayApis.remindersAdherenceLog,
      data: LogAdherenceRequest(reminderId: reminderId, taken: taken).toJson(),
    );
  }

  @override
  Future<void> snooze({required String reminderId, int minutes = 30}) async {
    final dio = await _gateway.dio();
    await dio.post(
      AstraGatewayApis.remindersSnooze,
      data: SnoozeRequest(reminderId: reminderId, minutes: minutes).toJson(),
    );
  }

  /// The create endpoint's response has no fixed schema in the published
  /// OpenAPI spec, so this checks the field names the rest of that API
  /// uses elsewhere (`reminder_id`, or a bare `id`) rather than assuming
  /// one is correct.
  String? _extractReminderId(dynamic data) {
    if (data is! Map) {
      logger.w('Unexpected reminder create response shape: $data');
      return null;
    }
    final id =
        data['reminder_id'] ?? data['id'] ?? data['data']?['reminder_id'];
    if (id == null) {
      logger.w('No reminder id found in create response: $data');
      return null;
    }
    return id.toString();
  }
}
