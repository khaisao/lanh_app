/// The fixed water reminder schedule from the Menu design: every 2 hours
/// from 9:00 to 19:00 local time. Not user-editable; reminders fire every
/// day whether or not the day's water goal is already met.
abstract final class WaterReminderSchedule {
  static const firstHour = 9;
  static const lastHour = 19;
  static const everyHours = 2;

  /// Reminder hours of a day: 9, 11, 13, 15, 17, 19.
  static final hours = [
    for (var hour = firstHour; hour <= lastHour; hour += everyHours) hour,
  ];

  /// The hour of the next reminder after [now]; the day's first reminder
  /// once today's last one has passed.
  static int nextHour(DateTime now) => hours.firstWhere(
    (hour) => hour * 60 > now.hour * 60 + now.minute,
    orElse: () => hours.first,
  );
}
