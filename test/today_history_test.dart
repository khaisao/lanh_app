import 'package:flutter/rendering.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/progress/progress.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/features/weight/domain/weight_entry.dart';
import 'package:lanh_app/features/weight/presentation/weight_ruler.dart';
import 'package:lanh_app/features/weight/weight_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_meal_log_repository.dart';
import 'support/test_water_log_repository.dart';
import 'support/test_weight_repository.dart';

/// Home by day, weigh-ins, meal delete and Nhìn lại, through the real
/// screens with in-memory repositories.
void main() {
  late TestMealLogRepository meals;
  late TestWaterLogRepository water;
  late TestWeightRepository weights;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int n, [int hour = 12]) =>
      DateTime(today.year, today.month, today.day - n, hour);

  Goal goal() => Goal(
    type: GoalType.lose,
    currentWeight: 53,
    createdAt: daysAgo(20),
    updatedAt: daysAgo(20),
  );

  Future<void> logMeal(String name, double kcal, DateTime at) => meals.save(
    analysis: MealAnalysis(
      requestId: '$name-$at',
      items: [
        MealAnalysisItem(
          id: name,
          name: name,
          portion: null,
          nutrition: MealNutrition(
            caloriesKcal: kcal,
            proteinGrams: 20,
            carbohydrateGrams: 60,
            fatGrams: 10,
          ),
        ),
      ],
    ),
    source: MealLogSource.voice,
    portionScale: 1,
    createdAt: at,
  );

  setUp(() {
    meals = TestMealLogRepository();
    water = TestWaterLogRepository();
    weights = TestWeightRepository();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Size size = const Size(390, 1600),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGoalProvider.overrideWithValue(AsyncData(goal())),
          profileEnergyTargetProvider.overrideWithValue(1600),
          waterGoalGlassesProvider.overrideWithValue(8),
          mealLogRepositoryProvider.overrideWithValue(meals),
          waterLogRepositoryProvider.overrideWithValue(water),
          weightRepositoryProvider.overrideWithValue(weights),
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
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String title(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('today-title'))).data!;

  Finder dayChip(DateTime day) =>
      find.byKey(Key('today-day-${day.month}-${day.day}'));

  /// The big number on the weight sheet, e.g. "52,8 kg".
  String shownWeight(WidgetTester tester) => tester
      .widget<RichText>(
        find.descendant(
          of: find.byKey(const Key('weight-value')),
          matching: find.byType(RichText),
        ),
      )
      .text
      .toPlainText();

  /// Moves the weight ruler by [ticks] of 0,1 kg (negative: lighter), the
  /// way a drag scrolls it.
  Future<void> moveRuler(WidgetTester tester, int ticks) async {
    final scroll = tester
        .widget<ListView>(find.byKey(const Key('weight-ruler')))
        .controller!;
    scroll.jumpTo(scroll.offset + ticks * WeightRuler.tickGap);
    await tester.pumpAndSettle();
  }

  /// A real finger drag across the ruler, [dx] logical pixels.
  Future<void> dragRuler(WidgetTester tester, double dx) async {
    await tester.drag(find.byKey(const Key('weight-ruler')), Offset(dx, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('a past day is read-only and the text action returns', (
    tester,
  ) async {
    await logMeal('Cơm tấm sườn', 620, daysAgo(1));
    await logMeal('Phở bò', 450, daysAgo(0, 7));
    water.logs.add((daysAgo(1), 250));
    await pump(tester, const TodayScreen());

    expect(title(tester), 'Hôm nay');
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.byKey(const Key('today-back-to-today')), findsNothing);
    final strip = find.byKey(const Key('today-day-strip'));
    final stripTop = tester.getTopLeft(strip).dy;

    await tester.tap(dayChip(daysAgo(3)));
    await tester.pumpAndSettle();
    // An older day: weekday title, date line without repeating it.
    final weekday = title(tester);
    expect(weekday, isNot(contains('Hôm')));
    expect(find.textContaining('$weekday,'), findsNothing);
    expect(find.textContaining(' tháng '), findsOneWidget);
    expect(tester.getTopLeft(strip).dy, stripTop); // no jump

    await tester.tap(dayChip(daysAgo(1)));
    await tester.pumpAndSettle();
    expect(title(tester), 'Hôm qua');
    expect(find.text('Cơm tấm sườn'), findsOneWidget);
    expect(find.text('Phở bò'), findsNothing);
    expect(find.text('250 / 2.000 ml'), findsOneWidget);
    // No logging or weighing on a past day.
    expect(find.byKey(const Key('today-weight-update')), findsNothing);
    await tester.tap(find.byKey(const Key('today-water-glass-3')));
    await tester.pumpAndSettle();
    expect(await water.countForDate(today), 0);
    expect(await water.countForDate(daysAgo(1)), 1);

    await tester.tap(find.byKey(const Key('today-back-to-today')));
    await tester.pumpAndSettle();
    expect(title(tester), 'Hôm nay');
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.byKey(const Key('today-weight-update')), findsOneWidget);
  });

  testWidgets('an empty past day says so instead of showing zero', (
    tester,
  ) async {
    await pump(tester, const TodayScreen());
    await tester.tap(dayChip(daysAgo(3)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-empty-day')), findsOneWidget);
    expect(find.text('Chưa ghi bữa'), findsOneWidget);
    expect(find.text('Chưa có món nào trong ngày này'), findsOneWidget);
    expect(find.text('Chưa ghi'), findsOneWidget); // water
    expect(find.byKey(const Key('today-first-meal')), findsNothing);
  });

  testWidgets('weigh-in: profile weight, step, save, replace and delete', (
    tester,
  ) async {
    await pump(tester, const TodayScreen());
    // Before any weigh-in, the profile weight stands in.
    expect(find.textContaining('53,0 kg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    expect(shownWeight(tester), '53,0 kg');
    expect(find.byKey(const Key('weight-delete')), findsNothing); // no delete
    expect(find.byKey(const Key('weight-day')), findsNothing); // today only
    // Drag the ruler right by two ticks: 0,2 kg less.
    await moveRuler(tester, -2);
    expect(shownWeight(tester), '52,8 kg');
    await tester.tap(find.byKey(const Key('weight-save')));
    await tester.pumpAndSettle();
    expect(weights.entries[today]?.kg, 52.8);
    // Today's own weigh-in needs no date: the header already says it.
    expect(find.text('52,8 kg', findRichText: true), findsOneWidget);

    // Saving again replaces today's number.
    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    expect(shownWeight(tester), '52,8 kg');
    await moveRuler(tester, -2);
    await tester.tap(find.byKey(const Key('weight-save')));
    await tester.pumpAndSettle();
    expect(weights.entries.length, 1);
    expect(weights.entries[today]?.kg, 52.6);
  });

  testWidgets('the ruler stops at 20 and 300 kg', (tester) async {
    await pump(tester, const TodayScreen());
    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    await dragRuler(tester, 5000); // finger right: lighter
    expect(shownWeight(tester), '20,0 kg');
    await dragRuler(tester, -30000); // past 300 kg
    expect(shownWeight(tester), '300,0 kg');
  });

  testWidgets('screen readers step the ruler by 0,1 kg', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const TodayScreen());
    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    final ruler = find.semantics.byPredicate(
      (node) => node.getSemanticsData().flagsCollection.isSlider,
    );
    final node = ruler.evaluate().single;
    expect(node.value, '53,0 kg');
    expect(node.increasedValue, '53,1 kg');
    tester.semantics.performAction(ruler, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(shownWeight(tester), '53,1 kg');
    semantics.dispose();
  });

  testWidgets('a failed weigh-in keeps the sheet and its number', (
    tester,
  ) async {
    weights.failWrite = true;
    await pump(tester, const TodayScreen());
    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weight-sheet')), findsOneWidget);
    expect(find.text('Chưa lưu được cân nặng. Thử lại nhé.'), findsOneWidget);
    expect(shownWeight(tester), '53,0 kg');
  });

  testWidgets('meal sheet deletes after confirmation only', (tester) async {
    await logMeal('Bún chả', 520, daysAgo(0, 7));
    await pump(tester, const TodayScreen());
    await tester.tap(find.text('Bún chả'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-detail-sheet')), findsOneWidget);
    expect(find.byKey(const Key('meal-detail-kcal')), findsOneWidget);
    // 20 g protein, 60 g carbs, 10 g fat: 80 / 240 / 90 kcal of 410.
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('59%'), findsOneWidget);
    expect(find.text('22%'), findsOneWidget);
    // The colour bar is drawn with height, not collapsed to zero.
    final bar = find.byKey(const Key('meal-energy-bar'));
    final parts = find.descendant(of: bar, matching: find.byType(ColoredBox));
    expect(parts, findsNWidgets(3));
    for (final part in parts.evaluate()) {
      expect(part.size!.height, greaterThan(0));
    }

    await tester.tap(find.byKey(const Key('meal-delete')));
    await tester.pumpAndSettle();
    // The dialog names the meal and its kcal; "Giữ lại" keeps it.
    expect(
      find.text('Bún chả · 520 kcal sẽ bị xoá khỏi nhật ký.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('meal-delete-cancel')));
    await tester.pumpAndSettle();
    expect(meals.saved, hasLength(1));

    await tester.tap(find.byKey(const Key('meal-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-delete-confirm')));
    await tester.pumpAndSettle();
    expect(meals.saved, isEmpty);
    expect(find.byKey(const Key('meal-detail-sheet')), findsNothing);
    expect(find.text('Bún chả'), findsNothing);
    expect(find.byKey(const Key('today-first-meal')), findsOneWidget);
  });

  testWidgets('a failed delete keeps the meal and says so', (tester) async {
    await logMeal('Bún chả', 520, daysAgo(0, 7));
    meals.failDelete = true;
    await pump(tester, const TodayScreen());
    await tester.tap(find.text('Bún chả'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-delete-confirm')));
    await tester.pumpAndSettle();
    expect(meals.saved, hasLength(1));
    expect(find.text('Chưa xoá được bữa. Thử lại nhé.'), findsOneWidget);
  });

  testWidgets('a past meal opens without delete', (tester) async {
    await logMeal('Bánh mì thịt', 420, daysAgo(2));
    await pump(tester, const TodayScreen());
    await tester.tap(dayChip(daysAgo(2)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bánh mì thịt'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-detail-sheet')), findsOneWidget);
    expect(find.byKey(const Key('meal-delete')), findsNothing);
  });

  testWidgets('Nhìn lại: a thin week asks for more days', (tester) async {
    await logMeal('Phở bò', 1910, daysAgo(2));
    await pump(tester, const ProgressScreen());
    expect(find.byKey(const Key('review-thin')), findsOneWidget);
    expect(find.text('Ghi thêm 2 ngày để xem phân tích'), findsOneWidget);
    expect(find.text('1 ngày vượt kế hoạch'), findsOneWidget);
    expect(find.byKey(const Key('review-findings')), findsNothing);
  });

  testWidgets('Nhìn lại: a logged week shows verdict, numbers and chart', (
    tester,
  ) async {
    for (var back = 1; back <= 7; back++) {
      if (back == 3) continue; // one day without meals
      await logMeal('Bữa $back', back.isEven ? 1900 : 1500, daysAgo(back));
    }
    await logMeal('Hôm nay', 3000, daysAgo(0)); // not part of the review
    await weights.save(WeightEntry(day: daysAgo(6), kg: 53));
    await weights.save(WeightEntry(day: daysAgo(1), kg: 52.8));
    water.logs.add((daysAgo(1), 250));
    await pump(tester, const ProgressScreen());

    expect(find.byKey(const Key('review-verdict-onTrack')), findsOneWidget);
    expect(find.text('Đúng hướng mục tiêu'), findsOneWidget);
    expect(find.text('6/7'), findsOneWidget);
    expect(find.text('2 lần cân'), findsOneWidget);
    expect(find.text('Chưa ghi'), findsOneWidget); // the empty day's bar
    expect(find.byKey(const Key('review-over-days')), findsOneWidget);
    final meter = find.byKey(const Key('review-plan-meter'));
    expect(tester.getSize(meter).height, greaterThan(0));
    for (final part
        in find
            .descendant(of: meter, matching: find.byType(Expanded))
            .evaluate()) {
      expect(part.size!.height, greaterThan(0));
    }
    expect(find.text('1/1 ngày đủ ly'), findsNothing);
    expect(find.text('0/1 ngày đủ ly'), findsOneWidget);
    // One glass on average against the goal of 8: one filled dot of eight.
    expect(
      find.descendant(
        of: find.byKey(const Key('review-water-dots')),
        matching: find.byType(DecoratedBox),
      ),
      findsNWidgets(8),
    );
    expect(find.text('3.000'), findsNothing);
  });

  testWidgets('large text on a small phone keeps every new surface whole', (
    tester,
  ) async {
    for (var back = 1; back <= 7; back++) {
      await logMeal('Bữa $back', back.isEven ? 1900 : 1500, daysAgo(back));
    }
    await logMeal('Bún chả', 520, daysAgo(0, 7));
    await weights.save(WeightEntry(day: daysAgo(6), kg: 53));
    await weights.save(WeightEntry(day: daysAgo(1), kg: 52.8));
    const small = Size(320, 700);
    await pump(tester, const ProgressScreen(), size: small, textScale: 2);
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-findings')),
      200,
    );
    expect(tester.takeException(), isNull);

    await pump(tester, const TodayScreen(), size: small, textScale: 2);
    final update = find.byKey(const Key('today-weight-update'));
    await tester.scrollUntilVisible(update, 200);
    await tester.ensureVisible(update);
    await tester.pumpAndSettle();
    await tester.tap(update);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weight-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('weight-sheet-close')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Bún chả'), 200);
    await tester.ensureVisible(find.text('Bún chả'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bún chả'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-detail-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reaching the water goal under Reduce Motion lays out cleanly', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    for (var i = 0; i < 7; i++) {
      water.logs.add((daysAgo(0, 8), 250));
    }
    await pump(tester, const TodayScreen());
    await tester.tap(find.byKey(const Key('today-water-glass-7')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-water-reached')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
