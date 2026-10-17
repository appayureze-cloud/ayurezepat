import 'dart:convert';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../v2/utils/logger.dart';
import '../../case/data/case_history_store.dart';
import '../../wellness/data/wellness_goal_store.dart';
import '../../wellness/data/wellness_log_store.dart';
import 'doctor_sharing_consent_store.dart';

/// Exports everything this app actually stores on-device into one JSON
/// file the patient can keep or share - there is no backend "download my
/// data" endpoint (see PrivacyDataScreen's doc comment), so this covers
/// only local state: the wellness log/goals, the local companion case
/// history, and doctor-sharing preferences. It deliberately does NOT claim
/// to include anything that lives only on the backend (prescriptions,
/// orders, consultations) - inventing that content here would be worse
/// than not exporting it.
class LocalDataExportService {
  LocalDataExportService._();

  /// Returns the path of the written file, or null on failure (toast/log
  /// already handled by the caller via the thrown exception message).
  static Future<String> exportToFile() async {
    final wellnessEntries =
        (await WellnessLogStore.getAll()).map((e) => e.toJson()).toList();
    final wellnessGoals =
        (await WellnessGoalStore.getAll()).map((g) => g.toJson()).toList();
    final caseHistory = (await CaseHistoryStore.getHistory())
        .map((entry) => entry.$1.toJson())
        .toList();
    final sharingConsents = (await DoctorSharingConsentStore.getAll())
        .map((c) => c.toJson())
        .toList();

    final payload = {
      'exported_at': DateTime.now().toIso8601String(),
      'note': 'This covers only data stored on this device. Prescriptions, '
          'orders and consultations live on the server and are not '
          'included here - contact support for those.',
      'wellness_log': wellnessEntries,
      'wellness_goals': wellnessGoals,
      'companion_case_history': caseHistory,
      'doctor_sharing_preferences': sharingConsents,
    };

    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    }
    if (baseDir == null) {
      throw Exception('Unable to access storage directory.');
    }

    final pathSegments = baseDir.path.split('/');
    final rootPath = pathSegments.take(4).join('/');
    final outputDirectory = '$rootPath/Download/Ayureze';
    await Directory(outputDirectory).create(recursive: true);

    final fileName =
        'ayureze-my-data-${DateTime.now().millisecondsSinceEpoch}.json';
    final filePath = '$outputDirectory/$fileName';
    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return filePath;
  }

  static Future<void> exportAndOpen() async {
    try {
      final path = await exportToFile();
      await OpenFilex.open(path);
    } catch (e) {
      logger.e('Local data export failed: $e');
      rethrow;
    }
  }
}
