import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/water_reminder_scheduler.dart';

/// Water reminders as daily local notifications via
/// flutter_local_notifications. Android uses inexact alarms, so a reminder
/// may arrive a few minutes late; that avoids the exact-alarm permission.
class LocalNotificationsWaterReminderScheduler
    implements WaterReminderScheduler {
  LocalNotificationsWaterReminderScheduler([
    FlutterLocalNotificationsPlugin? plugin,
  ]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;
  VoidCallback? _onOpen;

  /// Notification ids 9000 + hour, so cancelling never touches other
  /// notifications the app may add later.
  static const _idBase = 9000;
  static const _channelId = 'water_reminders';

  @override
  Future<void> initialize({VoidCallback? onOpen}) {
    if (onOpen != null) _onOpen = onOpen;
    return _ready ??= _plugin
        .initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            // The prompt is shown only when the user turns reminders on.
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestSoundPermission: false,
              requestBadgePermission: false,
            ),
          ),
          onDidReceiveNotificationResponse: (_) => _onOpen?.call(),
        )
        .then((_) {});
  }

  @override
  Future<bool> hasPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    final ios = await _ios?.checkPermissions();
    return ios?.isEnabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(
          alert: true,
          sound: true,
          badge: false,
        ) ??
        false;
  }

  @override
  Future<void> scheduleDaily(
    List<int> hours,
    WaterReminderMessage message,
  ) async {
    await initialize();
    await _useDeviceTimeZone();
    await cancel();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        message.channel,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final now = tz.TZDateTime.now(tz.local);
    for (final hour in hours) {
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: _idBase + hour,
        scheduledDate: at,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: message.title,
        body: message.body,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancel() async {
    await initialize();
    for (var hour = 0; hour < 24; hour++) {
      await _plugin.cancel(id: _idBase + hour);
    }
  }

  @override
  Future<void> openSettings() => openAppSettings();

  Future<void> _useDeviceTimeZone() async {
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
}
