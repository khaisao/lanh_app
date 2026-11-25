import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/local_notifications_water_reminder_scheduler.dart';
import 'data/preferences_water_reminder_repository.dart';
import 'domain/water_reminder_repository.dart';
import 'domain/water_reminder_schedule.dart';
import 'domain/water_reminder_scheduler.dart';

final waterReminderRepositoryProvider = Provider<WaterReminderRepository>(
  (ref) => PreferencesWaterReminderRepository(SharedPreferencesAsync()),
);

final waterReminderSchedulerProvider = Provider<WaterReminderScheduler>(
  (ref) => LocalNotificationsWaterReminderScheduler(),
);

/// Outcome of flipping the water reminder switch.
enum WaterReminderChange { enabled, disabled, permissionDenied }

/// Whether water reminders are on: saved as on and notifications allowed.
final waterReminderProvider = AsyncNotifierProvider<WaterReminder, bool>(
  WaterReminder.new,
);

class WaterReminder extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final saved = await ref.read(waterReminderRepositoryProvider).readEnabled();
    if (!saved) return false;
    // Notifications turned off in system settings count as off.
    return ref.read(waterReminderSchedulerProvider).hasPermission();
  }

  /// Turns reminders on (asking for permission first) or off.
  Future<WaterReminderChange> setEnabled(
    bool enabled, {
    required WaterReminderMessage message,
  }) async {
    final scheduler = ref.read(waterReminderSchedulerProvider);
    final repository = ref.read(waterReminderRepositoryProvider);
    if (!enabled) {
      state = const AsyncData(false);
      await scheduler.cancel();
      await repository.saveEnabled(false);
      return WaterReminderChange.disabled;
    }
    if (!await scheduler.requestPermission()) {
      state = const AsyncData(false);
      return WaterReminderChange.permissionDenied;
    }
    await scheduler.scheduleDaily(WaterReminderSchedule.hours, message);
    await repository.saveEnabled(true);
    if (ref.mounted) state = const AsyncData(true);
    return WaterReminderChange.enabled;
  }
}
