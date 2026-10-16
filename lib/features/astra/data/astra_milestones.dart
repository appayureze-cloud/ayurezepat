import '../../../v2/utils/logger.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_client.dart';

/// Best-effort, non-blocking milestone recording (`POST /api/companion/
/// milestone/add`) - confirmed live and attaches to a journey_id (unlike
/// `case/progress`, which needs a real doctor-created case_id this app
/// can't always supply). A failure here must never surface to the user or
/// block whatever real action (a check-in, a case closure) triggered it.
Future<void> recordMilestone({
  required String journeyId,
  required String milestoneType,
  required String description,
}) async {
  try {
    final dio = await AstraGatewayClient().dio();
    await dio.post(
      AstraGatewayApis.companionMilestoneAdd,
      data: {
        'journey_id': journeyId,
        'milestone_type': milestoneType,
        'description': description,
      },
    );
  } catch (e) {
    logger.w('Failed to record milestone "$milestoneType": $e');
  }
}
