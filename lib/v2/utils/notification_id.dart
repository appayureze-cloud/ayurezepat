/// Dart's String.hashCode isn't guaranteed to fit the 32-bit signed range
/// flutter_local_notifications/Android expects for a notification id - mask
/// it down so zonedSchedule/cancel never get an out-of-range value. Shared
/// by every feature that schedules local notifications (smart order
/// re-prompts, dose reminders).
int notificationIdFor(String key) => key.hashCode & 0x7fffffff;
