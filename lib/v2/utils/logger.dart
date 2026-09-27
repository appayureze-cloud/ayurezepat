import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:logger/logger.dart';

/// App-wide logger. Disabled in release builds so auth tokens, request
/// bodies and other PII that call sites pass to `logger.*` never end up in
/// release logcat/console output. Debug/profile builds keep full output.
var logger = Logger(
  level: kReleaseMode ? Level.off : Level.debug,
  printer: PrettyPrinter(
    methodCount: 2,
    // Number of method calls to be displayed
    errorMethodCount: 8,
    // Number of method calls if stacktrace is provided
    lineLength: 120,
    // Width of the output
    colors: true,
    // Colorful log messages
    printEmojis: true,
    // Print an emoji for each log message
    // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
