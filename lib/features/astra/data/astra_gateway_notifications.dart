import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';

/// Registers this device's FCM token with the Astra gateway
/// (`POST /api/v1/notifications/store-fcm-token`, `security: none`,
/// confirmed live during the Phase 4 audit), so the gateway's own
/// notification system - confirmed operational via its health check - can
/// push to this device directly, independent of the main backend's FCM
/// wiring. Best-effort: call sites should not let a failure here block
/// anything else.
Future<void> storeFcmTokenWithGateway(String patientId) async {
  final fcmToken =
      SharedPreferenceHelper.getString(Preferences.notificationRegisterKey);
  if (fcmToken == null || fcmToken.isEmpty) return;

  final gateway = AstraGatewayClient();
  final dio = await gateway.dio();
  await dio.post(
    AstraGatewayApis.notificationsStoreFcmToken,
    data: {'patient_id': patientId, 'fcm_token': fcmToken},
  );
}
