/// Remembers whether the user turned water reminders on.
abstract interface class WaterReminderRepository {
  Future<bool> readEnabled();

  Future<void> saveEnabled(bool enabled);
}
