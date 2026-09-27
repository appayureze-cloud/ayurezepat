import 'dart:io';

import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Downloads a remote PDF to local storage and opens it with the device's
/// PDF viewer. Shared by the appointment prescription download button and
/// PrescriptionDetailScreen's "View PDF" action.
Future<void> downloadAndOpenPdf(String url,
    {String fileNamePrefix = 'Ayureze'}) async {
  try {
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
      Fluttertoast.showToast(msg: 'Unable to access storage directory.');
      return;
    }

    final pathSegments = baseDir.path.split('/');
    final rootPath = pathSegments.take(4).join('/');
    final outputDirectory = '$rootPath/Download/Ayureze';
    await Directory(outputDirectory).create(recursive: true);

    final fileName =
        '$fileNamePrefix-${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '$outputDirectory/$fileName';

    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      Fluttertoast.showToast(
          msg: 'Could not download PDF (${response.statusCode}).');
      return;
    }

    final bytes = await response.fold<List<int>>(
      <int>[],
      (previous, element) => previous..addAll(element),
    );
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await OpenFilex.open(filePath);
  } catch (e) {
    logger.e('downloadAndOpenPdf failed: $e');
    Fluttertoast.showToast(msg: 'Could not open PDF.');
  }
}
