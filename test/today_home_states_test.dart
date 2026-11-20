import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/today/presentation/today_dashboard.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_water_log_repository.dart';

/// Every Home state of the Sleek design (Home 01–14), driven through the
/// real TodayScreen with provider overrides instead of fixed widgets.
void main() {
  final now = DateTime.utc(2026, 11, 20, 12);
  var nextId = 1;

  MealLog meal(String name, double? kcal, {int? id}) => MealLog(
    id: id ?? nextId++,
    requestId: 'r$name',
    source: MealLogSource.photo,
    createdAt: now,
    portionScale: 1,
    items: [
      MealLogItem(
        id: name,
        name: name,
        portion: null,
        nutrition: MealNutrition(caloriesKcal: kcal),
      ),
    ],
    totalCalories: kcal,
  );

  Goal goal(GoalType type) => Goal(type: type, createdAt: now, updatedAt: now);

  Future<void> pumpHome(
    WidgetTester tester, {
    AsyncValue<Goal?> goalValue = const AsyncLoading(),
    int? target,
    Future<List<MealLog>> Function()? meals,
    Size size = const Size(390, 844),
    double textScale = 1,
    List<Override> extra = const [],
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGoalProvider.overrideWithValue(goalValue),
          profileEnergyTargetProvider.overrideWithValue(target),
          todayMealLogsProvider.overrideWith(
            (ref) => meals?.call() ?? Completer<List<MealLog>>().future,
          ),
          waterLogRepositoryProvider.overrideWithValue(
            TestWaterLogRepository(),
          ),
          ...extra,
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const TodayScreen(),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // goal, target, meals' kcal, headline unit, status sentence.
  final planned = <(String, GoalType, int, List<double>, String, String)>[
    (
      'Home 01',
      GoalType.gain,
      2500,
      [],
      '/ 2.500 kcal',
      'Còn 2.500 kcal nữa là đạt mục tiêu',
    ),
    (
      'Home 02',
      GoalType.gain,
      2500,
      [580, 400],
      '/ 2.500 kcal',
      'Còn 1.520 kcal nữa là đạt mục tiêu',
    ),
    (
      'Home 03',
      GoalType.gain,
      2500,
      [940, 620, 580, 400],
      '/ 2.500 kcal',
      'Đã đạt mục tiêu hôm nay',
    ),
    (
      'Home 04',
      GoalType.lose,
      1600,
      [],
      '/ 1.600 kcal',
      'Còn 1.600 kcal trong kế hoạch',
    ),
    (
      'Home 05',
      GoalType.lose,
      1800,
      [580, 400],
      '/ 1.800 kcal',
      'Còn 820 kcal trong kế hoạch',
    ),
    (
      'Home 06',
      GoalType.lose,
      1800,
      [620, 200, 580, 400],
      '/ 1.800 kcal',
      'Vừa đủ kế hoạch hôm nay',
    ),
    (
      'Home 07',
      GoalType.lose,
      1800,
      [870, 200, 580, 400],
      '/ 1.800 kcal',
      'Hơn kế hoạch 250 kcal hôm nay',
    ),
    (
      'Home 08',
      GoalType.maintain,
      2100,
      [],
      'kcal',
      'Thêm 1.900⁠–⁠2.300 kcal là vào dải',
    ),
    (
      'Home 09',
      GoalType.maintain,
      2100,
      [580, 400],
      'kcal',
      'Thêm 920⁠–⁠1.320 kcal là vào dải',
    ),
    (
      'Home 10',
      GoalType.maintain,
      2100,
      [720, 100, 580, 700],
      'kcal',
      'Đang trong dải duy trì',
    ),
    (
      'Home 11',
      GoalType.maintain,
      2100,
      [870, 150, 580, 850],
      'kcal',
      'Hơn dải 150 kcal hôm nay',
    ),
  ];

  for (final (name, type, target, kcal, unit, sentence) in planned) {
    for (final (size, scale) in const [
      (Size(320, 700), 1.0),
      (Size(390, 844), 1.0),
      (Size(430, 932), 1.0),
      (Size(320, 700), 2.0),
    ]) {
      testWidgets('$name ${type.name} reads "$sentence" at '
          '${size.width.toInt()} ${scale}x', (tester) async {
        await pumpHome(
          tester,
          goalValue: AsyncData(goal(type)),
          target: target,
          meals: () async => [for (final k in kcal) meal('Món $k', k)],
          size: size,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(Key('today-energy-${type.name}')), findsOneWidget);
        final total = kcal.fold<double>(0, (a, b) => a + b);
        final value = NumberFormat.decimalPattern('vi').format(total);
        expect(
          find.descendant(
            of: find.byKey(const Key('today-energy-value')),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
        expect(find.text(unit), findsOneWidget);
        expect(find.text(sentence), findsOneWidget);
        expect(find.text('Ước tính'), findsOneWidget);

        // Read-only meter: every painted part stays inside the track.
        final track = tester.getRect(
          find.byKey(const Key('today-energy-meter')),
        );
        for (final key in const [
          'today-energy-fill',
          'today-energy-zone',
          'today-energy-overrun',
        ]) {
          for (final part in tester.widgetList(find.byKey(Key(key)))) {
            final rect = tester.getRect(find.byWidget(part));
            expect(rect.top, greaterThanOrEqualTo(track.top - .01));
            expect(rect.bottom, lessThanOrEqualTo(track.bottom + .01));
            expect(rect.right, lessThanOrEqualTo(track.right + .01));
          }
        }
        final over = name == 'Home 07' || name == 'Home 11';
        expect(
          find.byKey(const Key('today-energy-overrun')),
          over ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('today-energy-status-ph-info-bold')),
          over ? findsOneWidget : findsNothing,
        );
        final maintain = type == GoalType.maintain;
        expect(
          find.text('Dải duy trì 1.900–2.300'),
          maintain ? findsOneWidget : findsNothing,
        );
        if (kcal.isEmpty) {
          await tester.scrollUntilVisible(
            find.byKey(const Key('today-first-meal')),
            200,
          );
        }
        expect(
          find.byKey(const Key('today-first-meal')),
          kcal.isEmpty ? findsOneWidget : findsNothing,
        );
      });
    }
  }

  testWidgets('Home 12: first reads show placeholders, not zero', (
    tester,
  ) async {
    await pumpHome(tester, settle: false);
    expect(find.byKey(const Key('today-energy-loading')), findsOneWidget);
    expect(find.byKey(const Key('today-journal-loading')), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.bySemanticsLabel('Đang tải hồ sơ…'), findsOneWidget);
  });

  testWidgets('Home 13: read errors are calm and retryable', (tester) async {
    var mealReads = 0;
    await pumpHome(
      tester,
      goalValue: AsyncError(StateError('disk'), StackTrace.empty),
      meals: () {
        mealReads++;
        return Future.error(StateError('disk'));
      },
    );
    expect(find.byKey(const Key('today-energy-error')), findsOneWidget);
    expect(find.text('Chưa đọc được hồ sơ.'), findsOneWidget);
    expect(find.byKey(const Key('today-journal-error')), findsOneWidget);
    expect(find.text('Chưa đọc được nhật ký hôm nay.'), findsOneWidget);
    final reads = mealReads;
    await tester.tap(find.byKey(const Key('today-journal-retry')));
    await tester.pumpAndSettle();
    expect(mealReads, reads + 1);
  });

  testWidgets('a journal error with a plan does not invent a total', (
    tester,
  ) async {
    await pumpHome(
      tester,
      goalValue: AsyncData(goal(GoalType.lose)),
      target: 1800,
      meals: () => Future.error(StateError('disk')),
    );
    expect(find.byKey(const Key('today-energy-plain')), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.byKey(const Key('today-energy-meter')), findsNothing);
  });

  testWidgets('Home 14: a just-saved meal is confirmed and highlighted', (
    tester,
  ) async {
    final saved = meal('Cơm gà xào rau', 580, id: 99);
    late ProviderContainer container;
    await pumpHome(
      tester,
      goalValue: AsyncData(goal(GoalType.lose)),
      target: 1800,
      meals: () async => [saved, meal('Cháo trắng với trứng', 400)],
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(TodayScreen)),
    );
    container.read(lastSavedMealProvider.notifier).record(saved);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Đã lưu Cơm gà xào rau · 580 kcal'), findsOneWidget);
    final row = tester.widget<TodayMealRow>(
      find.byKey(const ValueKey('today-meal-99')),
    );
    expect(row.highlighted, isTrue);
    expect(find.text('Còn 820 kcal trong kế hoạch'), findsOneWidget);
    // The pill closes on its own and the highlight is released.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu Cơm gà xào rau · 580 kcal'), findsNothing);
    expect(container.read(lastSavedMealProvider), isNull);
  });

  testWidgets('reaching the plan taps once; opening a done day does not', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('tap');
        return null;
      },
    );
    var list = [meal('A', 1500)];
    await pumpHome(
      tester,
      goalValue: AsyncData(goal(GoalType.gain)),
      target: 2000,
      meals: () async => list,
    );
    expect(haptics, isEmpty);
    list = [meal('A', 1500), meal('B', 600)];
    ProviderScope.containerOf(tester.element(find.byType(TodayScreen)))
        .invalidate(todayMealLogsProvider);
    await tester.pumpAndSettle();
    expect(find.text('Đã đạt mục tiêu hôm nay'), findsOneWidget);
    expect(haptics, hasLength(1));
  });

  testWidgets('plans with no kcal target keep a plain card', (tester) async {
    await pumpHome(
      tester,
      goalValue: AsyncData(goal(GoalType.logOnly)),
      meals: () async => [meal('A', 400)],
    );
    expect(find.byKey(const Key('today-energy-plain')), findsOneWidget);
    expect(find.byKey(const Key('today-energy-meter')), findsNothing);
  });

  testWidgets('Reduce Motion draws the meter at its value at once', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpHome(
      tester,
      goalValue: AsyncData(goal(GoalType.lose)),
      target: 2000,
      meals: () async => [meal('A', 1000)],
    );
    final track = tester.getRect(find.byKey(const Key('today-energy-meter')));
    final fill = tester.getRect(find.byKey(const Key('today-energy-fill')));
    expect(fill.width, closeTo(track.width / 2, .5));
  });
}
