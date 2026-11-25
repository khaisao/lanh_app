import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/menu/menu.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/water_reminder/water_reminder.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_water_reminder.dart';

void main() {
  test('schedule is every 2 hours from 9:00 to 19:00', () {
    expect(WaterReminderSchedule.hours, [9, 11, 13, 15, 17, 19]);
    DateTime at(int h, [int m = 0]) => DateTime(2026, 11, 20, h, m);
    expect(WaterReminderSchedule.nextHour(at(6)), 9);
    expect(WaterReminderSchedule.nextHour(at(9)), 11);
    expect(WaterReminderSchedule.nextHour(at(10, 59)), 11);
    expect(WaterReminderSchedule.nextHour(at(18, 30)), 19);
    expect(WaterReminderSchedule.nextHour(at(19)), 9);
    expect(WaterReminderSchedule.nextHour(at(23)), 9);
  });

  late TestWaterReminderRepository repository;
  late TestWaterReminderScheduler scheduler;

  setUp(() {
    repository = TestWaterReminderRepository();
    scheduler = TestWaterReminderScheduler();
  });

  Future<void> pumpMenu(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    bool reduceMotion = true,
  }) async {
    // The background waves loop forever unless motion is reduced.
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGoalProvider.overrideWithValue(const AsyncData(null)),
          waterReminderRepositoryProvider.overrideWithValue(repository),
          waterReminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const MenuScreen(),
        ),
      ),
    );
    if (reduceMotion) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  final toggle = find.byKey(const Key('water-reminder-switch'));
  bool switchOn(WidgetTester tester) => tester.widget<Switch>(toggle).value;

  testWidgets('turning on schedules the six reminders and confirms', (
    tester,
  ) async {
    await pumpMenu(tester);
    expect(find.text('9:00 – 19:00 · mỗi 2 giờ'), findsOneWidget);
    expect(switchOn(tester), isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(switchOn(tester), isTrue);
    expect(scheduler.scheduled, [9, 11, 13, 15, 17, 19]);
    expect(scheduler.message?.title, 'Uống một cốc nước nhé 💧');
    expect(scheduler.message?.body, 'Chạm để ghi vào Lành.');
    expect(repository.enabled, isTrue);
    expect(find.textContaining('Đang bật · lần tới'), findsOneWidget);
    expect(find.text('Đã bật nhắc uống nước'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(switchOn(tester), isFalse);
    expect(scheduler.scheduled, isEmpty);
    expect(repository.enabled, isFalse);
  });

  testWidgets('denied permission keeps it off and offers Settings', (
    tester,
  ) async {
    scheduler
      ..permitted = false
      ..grantOnRequest = false;
    await pumpMenu(tester);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(switchOn(tester), isFalse);
    expect(scheduler.scheduled, isEmpty);
    expect(repository.enabled, isFalse);
    await tester.tap(find.text('Cài đặt'));
    expect(scheduler.settingsOpened, 1);
  });

  testWidgets('saved on but notifications revoked shows off', (tester) async {
    repository.enabled = true;
    scheduler.permitted = false;
    await pumpMenu(tester);
    expect(switchOn(tester), isFalse);
  });

  for (final size in const [
    Size(320, 700),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets('menu fits $size without overflow', (tester) async {
      repository.enabled = true;
      await pumpMenu(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.text('Thói quen'), findsOneWidget);
      expect(find.text('Riêng tư'), findsOneWidget);
      expect(find.text('Hỏi đáp và gửi phản hồi'), findsOneWidget);
    });
  }

  testWidgets('waves drift with motion and hold still when reduced', (
    tester,
  ) async {
    await pumpMenu(tester, reduceMotion: false);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);

    await pumpMenu(tester);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
