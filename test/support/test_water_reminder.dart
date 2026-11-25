import 'package:lanh_app/features/water_reminder/water_reminder.dart';

class TestWaterReminderRepository implements WaterReminderRepository {
  bool enabled = false;
  @override
  Future<bool> readEnabled() async => enabled;
  @override
  Future<void> saveEnabled(bool value) async => enabled = value;
}

class TestWaterReminderScheduler implements WaterReminderScheduler {
  bool permitted = true;
  bool grantOnRequest = true;
  List<int> scheduled = const [];
  WaterReminderMessage? message;
  int settingsOpened = 0;

  @override
  Future<void> initialize({void Function()? onOpen}) async {}
  @override
  Future<bool> hasPermission() async => permitted;
  @override
  Future<bool> requestPermission() async => permitted = grantOnRequest;
  @override
  Future<void> scheduleDaily(List<int> hours, WaterReminderMessage msg) async {
    scheduled = hours;
    message = msg;
  }

  @override
  Future<void> cancel() async => scheduled = const [];
  @override
  Future<void> openSettings() async => settingsOpened++;
}
