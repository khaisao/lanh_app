/// Text of one water reminder notification, localised by the caller.
typedef WaterReminderMessage = ({String channel, String title, String body});

/// The device's notification system for water reminders.
abstract interface class WaterReminderScheduler {
  /// Prepares the notification system once. [onOpen] runs when the user taps
  /// a water reminder while the app is alive; a cold start lands on Home.
  Future<void> initialize({void Function()? onOpen});

  /// Whether the app may show notifications right now.
  Future<bool> hasPermission();

  /// Shows the system permission prompt when it can; returns whether
  /// notifications are allowed afterwards.
  Future<bool> requestPermission();

  /// Replaces any scheduled reminders with one daily notification at each
  /// of [hours] (local time).
  Future<void> scheduleDaily(List<int> hours, WaterReminderMessage message);

  /// Cancels every scheduled water reminder.
  Future<void> cancel();

  /// Opens the app's system settings so the user can allow notifications.
  Future<void> openSettings();
}
