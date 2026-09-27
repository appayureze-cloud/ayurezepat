import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' show NotificationResponse;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../const/Palette.dart';

String timeUntil(DateTime targetDateTime) {
  final now = DateTime.now();
  final difference = targetDateTime.difference(now);

  if (difference.isNegative) {
    return 'Time has already passed';
  }

  final days = difference.inDays;
  final hours = difference.inHours % 24;
  final minutes = difference.inMinutes % 60;

  if (days >= 14) {
    final weeks = (days / 7).floor();
    return 'In $weeks week${weeks > 1 ? 's' : ''}';
  } else if (days > 0) {
    return 'In $days day${days > 1 ? 's' : ''}';
  } else if (hours > 0 && minutes > 0) {
    return 'In $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
  } else if (hours > 0) {
    return 'In $hours hour${hours > 1 ? 's' : ''}';
  } else if (minutes > 0) {
    return 'In $minutes minute${minutes > 1 ? 's' : ''}';
  } else {
    return 'In a few seconds';
  }
}

Widget paymentSection({
  required String title,
  required String value,
  Color? titleColor,
  Color? valueColor,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 30.w,
          child: Text(
            '$title',
            style: TextStyle(
              color: titleColor ?? Palette.black,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            '$value',
            style: TextStyle(
              color: valueColor ?? Palette.dark_grey,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

extension SentenceCase on String {
  String toSentenceCase() {
    if (this.trim().isEmpty) return this;
    String trimmed = this.trim();
    return trimmed
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }
}

// Date Format  Display user
class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

// Date Format pass Api
class DateUtilForPass {
  static const DATE_FORMAT = 'yyyy-MM-dd';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}


class NotificationHandler {
  static final ValueNotifier<NotificationResponse?> notificationResponse = ValueNotifier(null);

  static void handle(NotificationResponse response) {
    notificationResponse.value = response;
  }
}
