# Water reminders

Menu → Thói quen → **Nhắc uống nước** (`lib/features/water_reminder/`, design in [design-system.md](design-system.md#menu)).

## Behaviour

- Fixed schedule: 9:00, 11:00, 13:00, 15:00, 17:00, 19:00 local time, every day. Not editable. Reminders still fire after the day's water goal is met.
- Off: subtitle "9:00 – 19:00 · mỗi 2 giờ". On: "Đang bật · lần tới HH:00", refreshed every minute while the Menu is open.
- Turning on shows the system notification prompt. Allowed: six daily notifications are scheduled, the choice is saved (`lanh.waterReminder.enabled.v1` in shared preferences) and the "Đã bật nhắc uống nước" toast shows. Denied: the switch stays off and a toast offers **Cài đặt** (app settings).
- Turning off cancels the six notifications (ids 9009–9019).
- Saved on but notifications later blocked in system settings shows as off.
- Notification: "Uống một cốc nước nhé 💧" / "Chạm để ghi vào Lành.". Tapping it opens Home; it does not log a glass.
- The card's background waves drift continuously (8 s loop); Reduce Motion stops them. Widget tests that show the Menu must reduce motion, or `pumpAndSettle` never settles.
- Privacy and Help rows have no screen yet.

## Platform setup

- `flutter_local_notifications` + `timezone` + `flutter_timezone`. Android uses `inexactAllowWhileIdle`, so no exact-alarm permission; Android may deliver up to about an hour late (alarm window).
- Android: `RECEIVE_BOOT_COMPLETED`, the plugin's two receivers in `AndroidManifest.xml`, and core library desugaring in `android/app/build.gradle.kts`.
- iOS: `AppDelegate` sets the `UNUserNotificationCenter` delegate so reminders also show in the foreground. Not verified on a device yet.

## Verification (20/11/2026, emulator API 33)

System prompt shown; deny keeps the switch off with the Settings toast; allow schedules six alarms at 9–19 h (checked with `dumpsys alarm`); off leaves none. With the clock moved by `adb shell cmd alarm set-time`, the 9:00 notification posted at 9:00:05 with the right text and channel, tapping it from the Menu tab opened Home, and the "lần tới" label advanced on its own.

Moving the emulator clock forward leaves future-dated logcat lines; `flutter run` then attaches to a stale VM service URL and hangs. Run `adb logcat -c` after restoring the clock.
