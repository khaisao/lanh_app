import 'package:shared_preferences/shared_preferences.dart';

import '../domain/water_reminder_repository.dart';

class PreferencesWaterReminderRepository implements WaterReminderRepository {
  PreferencesWaterReminderRepository(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const _key = 'lanh.waterReminder.enabled.v1';

  @override
  Future<bool> readEnabled() async => await _preferences.getBool(_key) ?? false;

  @override
  Future<void> saveEnabled(bool enabled) => _preferences.setBool(_key, enabled);
}
