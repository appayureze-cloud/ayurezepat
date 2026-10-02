import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart' show flutterLocalNotificationsPlugin;

class NotificationService {
  static Future<void> showDownloadCompleteNotification(String filePath) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Channel for download notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Download Completed',
      'Prescription saved to: $filePath',
      notificationDetails,
      payload: filePath,
    );
  }
}
