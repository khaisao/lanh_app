import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_water_log_repository.dart';

void main() {
  late TestWaterLogRepository repository;
  late List<String> haptics;

  setUp(() {
    repository = TestWaterLogRepository();
    haptics = [];
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    ProfileSex sex = ProfileSex.male,
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String? ?? '');
        }
        return null;
      },
    );
    final now = DateTime.now().toUtc();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGoalProvider.overrideWithValue(
            AsyncData(
              Goal(type: GoalType.lose, createdAt: now, updatedAt: now),
            ),
          ),
          profileEnergyTargetProvider.overrideWithValue(1800),
          profileSexProvider.overrideWithValue(sex),
          todayMealLogsProvider.overrideWith((ref) async => const []),
          waterLogRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder glass(int index) => find.byKey(Key('today-water-glass-$index'));
  String amount(WidgetTester tester) {
    final widget = tester.widget(find.byKey(const Key('today-water-amount')));
    return widget is Text ? widget.data! : (widget as AppRollingText).text;
  }

  Future<void> tapGlass(WidgetTester tester, int index) async {
    await tester.tap(glass(index));
    await tester.pumpAndSettle();
  }

  testWidgets('the goal is 8 glasses for men and 6 for women', (tester) async {
    await pumpHome(tester);
    expect(glass(7), findsOneWidget);
    expect(glass(8), findsNothing);
    expect(amount(tester), 'Chưa ghi');

    await pumpHome(tester, sex: ProfileSex.female);
    expect(glass(5), findsOneWidget);
    expect(glass(6), findsNothing);
  });

  testWidgets('tapping an empty glass pours the next one and saves it', (
    tester,
  ) async {
    await pumpHome(tester);
    // Any empty glass pours the next free one, left to right.
    await tapGlass(tester, 5);
    expect(repository.logs, hasLength(1));
    expect(repository.logs.single.$2, 250);
    expect(amount(tester), '250 / 2.000 ml');
    expect(tester.getSemantics(glass(0)).label, 'Cốc 1, đã uống. Chạm để bỏ');
    expect(
      tester.getSemantics(glass(1)).label,
      'Cốc 2, chưa uống. Chạm để thêm 250 ml',
    );
    expect(haptics, contains('HapticFeedbackType.lightImpact'));
  });

  testWidgets('tapping a full glass removes the last one', (tester) async {
    final now = DateTime.now();
    repository.logs.addAll([(now, 250), (now, 250), (now, 250)]);
    await pumpHome(tester);
    expect(amount(tester), '750 / 2.000 ml');
    await tapGlass(tester, 0);
    expect(repository.logs, hasLength(2));
    expect(amount(tester), '500 / 2.000 ml');
    expect(
      tester.getSemantics(glass(2)).label,
      'Cốc 3, chưa uống. Chạm để thêm 250 ml',
    );
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
  });

  testWidgets('logging stops at the goal and says so once', (tester) async {
    final now = DateTime.now();
    repository.logs.addAll(List.filled(5, (now, 250)));
    await pumpHome(tester, sex: ProfileSex.female);
    expect(find.byKey(const Key('today-water-reached')), findsNothing);
    await tapGlass(tester, 5);
    expect(amount(tester), '1.500 / 1.500 ml');
    expect(find.text('Đã đủ nước hôm nay'), findsOneWidget);
    expect(haptics, contains('HapticFeedbackType.mediumImpact'));
    // At the goal every glass is full, so the notifier refuses more.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    await container.read(todayWaterProvider.notifier).add();
    await tester.pumpAndSettle();
    expect(repository.logs, hasLength(6));
  });

  testWidgets('fast taps are saved one after another', (tester) async {
    await pumpHome(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(glass(7));
      await tester.pump(const Duration(milliseconds: 2));
    }
    await tester.pumpAndSettle();
    expect(repository.logs, hasLength(3));
    expect(amount(tester), '750 / 2.000 ml');
  });

  testWidgets('a failed save restores the glass and explains', (tester) async {
    await pumpHome(tester);
    repository.failWrite = true;
    await tapGlass(tester, 0);
    expect(repository.logs, isEmpty);
    expect(amount(tester), 'Chưa ghi');
    expect(find.text('Chưa lưu được nước. Thử lại nhé.'), findsOneWidget);
  });

  testWidgets('a read error shows a retry instead of zero', (tester) async {
    repository.failRead = true;
    await pumpHome(tester);
    expect(find.text('Chưa đọc được nước hôm nay.'), findsOneWidget);
    expect(glass(0), findsNothing);
    repository.failRead = false;
    await tester.tap(find.byKey(const Key('today-water-retry')));
    await tester.pumpAndSettle();
    expect(glass(0), findsOneWidget);
  });

  testWidgets('the pour animates; Reduce Motion fills at once', (tester) async {
    await pumpHome(tester);
    await tester.tap(glass(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    // Mid-pour (the overshoot) the glass is springing, not at rest.
    final scales = tester
        .widgetList<Transform>(
          find.descendant(of: glass(0), matching: find.byType(Transform)),
        )
        .map((t) => t.transform.getMaxScaleOnAxis());
    expect(scales.any((s) => (s - 1).abs() > .01), isTrue);
    await tester.pumpAndSettle();

    await pumpHome(tester, reduceMotion: true);
    await tester.tap(glass(1));
    await tester.pump();
    final still = tester
        .widgetList<Transform>(
          find.descendant(of: glass(1), matching: find.byType(Transform)),
        )
        .map((t) => t.transform.getMaxScaleOnAxis());
    expect(still.every((s) => (s - 1).abs() < .001), isTrue);
    await tester.pumpAndSettle();
    expect(repository.logs, hasLength(2));
  });
}
