import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_flow.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/progress/progress.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/data/sqlite_water_log_repository.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/features/weight/data/sqlite_weight_repository.dart';
import 'package:lanh_app/features/weight/domain/weight_entry.dart';
import 'package:lanh_app/features/weight/weight_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// End-to-end food, history, weight, water and Nhìn lại scenarios on a
/// device. Meals come from scripted analyses below (test data only, never
/// shipped) and are stored in real SQLite files in a throwaway folder.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late SqliteMealLogRepository meals;
  late SqliteWaterLogRepository water;
  late SqliteWeightRepository weights;
  late ScriptedAnalysis analysis;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int n, [int hour = 12, int minute = 0]) =>
      DateTime(today.year, today.month, today.day - n, hour, minute);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lanh_scenarios');
    meals = SqliteMealLogRepository(databasePath: '${dir.path}/meals.db');
    water = SqliteWaterLogRepository(databasePath: '${dir.path}/water.db');
    weights = SqliteWeightRepository(databasePath: '${dir.path}/weight.db');
    analysis = ScriptedAnalysis();
  });
  tearDown(() => dir.delete(recursive: true));

  List<Override> overrides({
    GoalType goal = GoalType.lose,
    int target = 1600,
    int glasses = 8,
  }) => [
    profileGoalProvider.overrideWithValue(
      AsyncData(
        Goal(
          type: goal,
          currentWeight: 60,
          createdAt: daysAgo(30),
          updatedAt: daysAgo(30),
        ),
      ),
    ),
    profileEnergyTargetProvider.overrideWithValue(target),
    waterGoalGlassesProvider.overrideWithValue(glasses),
    mealLogRepositoryProvider.overrideWithValue(meals),
    mealAnalysisRepositoryProvider.overrideWithValue(analysis),
    waterLogRepositoryProvider.overrideWithValue(water),
    weightRepositoryProvider.overrideWithValue(weights),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    List<Override>? using,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: using ?? overrides(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: AppBackground(child: screen),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<MealPhoto> photo() async {
    final bytes = await rootBundle.load(
      'assets/design/images/dzdAuAChai1.jpeg',
    );
    return MealPhoto(bytes.buffer.asUint8List());
  }

  /// Opens the photo flow, estimates with [result], picks [scale], saves.
  Future<void> logPhotoMeal(
    WidgetTester tester,
    MealAnalysis result, {
    double scale = 1,
    bool doubleTapSave = false,
  }) async {
    analysis.next = result;
    await pump(tester, MealPhotoFlow(recoveredPhoto: await photo()));
    await tester.tap(find.byKey(const Key('meal-photo-estimate')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
    if (scale != 1) {
      final portion = find.byKey(Key('meal-portion-$scale'));
      await tester.ensureVisible(portion);
      await tester.pumpAndSettle();
      await tester.tap(portion);
      await tester.pumpAndSettle();
    }
    final save = find.byKey(const Key('meal-analysis-save'));
    await tester.tap(save);
    if (doubleTapSave) await tester.tap(save, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  group('food data through the photo flow', () {
    testWidgets('multi-dish meal at each portion saves the scaled total', (
      tester,
    ) async {
      // 200 + 380 = 580 kcal per portion.
      for (final (scale, kcal) in [(0.5, 290.0), (1.0, 580.0), (1.5, 870.0)]) {
        await logPhotoMeal(tester, comGa(), scale: scale);
        final saved = await meals.readForDate(today);
        expect(
          saved.first.totalCalories,
          closeTo(kcal, 1e-9),
          reason: '$scale',
        );
        expect(saved.first.items, hasLength(2));
        expect(saved.first.portionScale, scale);
      }
      expect(await meals.readForDate(today), hasLength(3));
    });

    testWidgets('a double tap on save stores one meal', (tester) async {
      await logPhotoMeal(tester, comGa(), doubleTapSave: true);
      expect(await meals.readForDate(today), hasLength(1));
    });

    testWidgets('unknown and zero kcal items are kept apart, not as zero', (
      tester,
    ) async {
      await logPhotoMeal(tester, mixedKnowledge());
      final saved = (await meals.readForDate(today)).single;
      // Only the known items add up: phở 450 + trà đá 0.
      expect(saved.totalCalories, 450);
      expect(saved.items.map((i) => i.nutrition.caloriesKcal), [450, 0, null]);
      await pump(tester, const TodayScreen());
      expect(find.text('450 kcal'), findsOneWidget);
    });

    testWidgets('long names and many dishes stay readable on Home', (
      tester,
    ) async {
      await logPhotoMeal(tester, buffet());
      final saved = (await meals.readForDate(today)).single;
      expect(saved.items, hasLength(8));
      expect(saved.totalCalories, closeTo(1385, 1e-9));
      await pump(tester, const TodayScreen());
      expect(find.text('1.385 kcal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no food and network failures save nothing; retry works', (
      tester,
    ) async {
      analysis.failures = [
        MealAnalysisFailureKind.noFood,
        MealAnalysisFailureKind.network,
      ];
      analysis.next = comGa();
      await pump(tester, MealPhotoFlow(recoveredPhoto: await photo()));
      await tester.tap(find.byKey(const Key('meal-photo-estimate')));
      await tester.pumpAndSettle();
      expect(find.text('Chưa ước lượng được'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa ước lượng được'), findsOneWidget);
      expect(await meals.readForDate(today), isEmpty);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
      // The retries reuse one request identity.
      expect(analysis.requestIds.toSet(), hasLength(1));
      await tester.tap(find.byKey(const Key('meal-analysis-discard')));
      await tester.pumpAndSettle();
      expect(await meals.readForDate(today), isEmpty);
    });

    testWidgets('detail sheet shows the energy split; delete updates Home', (
      tester,
    ) async {
      await logPhotoMeal(tester, comGa());
      await logPhotoMeal(tester, mixedKnowledge());
      await pump(tester, const TodayScreen());
      expect(find.text('580 kcal'), findsOneWidget);
      expect(find.text('450 kcal'), findsOneWidget);
      await tester.ensureVisible(find.text('Cơm trắng, Gà xào rau'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cơm trắng, Gà xào rau'));
      await tester.pumpAndSettle();
      // 34 g protein, 64 g carbs, 18.4 g fat → 136 / 256 / 165.6 kcal.
      expect(find.text('24%'), findsOneWidget);
      expect(find.text('46%'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      await tester.tap(find.byKey(const Key('meal-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('meal-delete-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Cơm trắng, Gà xào rau'), findsNothing);
      expect(find.text('450 kcal'), findsOneWidget);
      expect(await meals.readForDate(today), hasLength(1));
    });

    testWidgets('a meal without macros hides the split', (tester) async {
      await logPhotoMeal(tester, mixedKnowledge());
      await pump(tester, const TodayScreen());
      await tester.ensureVisible(find.textContaining('Phở bò'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Phở bò'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-energy-bar')), findsNothing);
      expect(find.text('450'), findsWidgets);
    });
  });

  group('days, water and weight', () {
    testWidgets('meals at 23:59 and 00:01 land on their own days', (
      tester,
    ) async {
      await saveMeal(meals, 'Bữa khuya', 300, daysAgo(1, 23, 59));
      await saveMeal(meals, 'Bữa sớm', 200, daysAgo(0, 0, 1));
      await pump(tester, const TodayScreen());
      expect(find.text('Bữa sớm'), findsOneWidget);
      expect(find.text('Bữa khuya'), findsNothing);
      final yesterday = daysAgo(1);
      await tester.tap(
        find.byKey(Key('today-day-${yesterday.month}-${yesterday.day}')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bữa khuya'), findsOneWidget);
      expect(find.text('Bữa sớm'), findsNothing);
    });

    testWidgets('water stops at a 6-glass goal and removes the last glass', (
      tester,
    ) async {
      await pump(tester, const TodayScreen(), using: overrides(glasses: 6));
      // Only six glasses are drawn; each empty one pours the next glass.
      expect(find.byKey(const Key('today-water-glass-6')), findsNothing);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(Key('today-water-glass-$i')));
        await tester.pumpAndSettle();
      }
      expect(await water.countForDate(today), 6);
      expect(find.text('Đã đủ nước hôm nay'), findsOneWidget);
      await tester.tap(find.byKey(const Key('today-water-glass-2')));
      await tester.pumpAndSettle();
      expect(await water.countForDate(today), 5);
    });

    testWidgets('the weight ruler drags within 20–300 kg and saves', (
      tester,
    ) async {
      await pump(tester, const TodayScreen());
      await tester.tap(find.byKey(const Key('today-weight-update')));
      await tester.pumpAndSettle();
      final ruler = find.byKey(const Key('weight-ruler'));
      // A finger flick far past either end stops at the limit.
      await tester.drag(ruler, const Offset(-40000, 0));
      await tester.pumpAndSettle();
      expect(find.text('300,0 kg', findRichText: true), findsOneWidget);
      await tester.drag(ruler, const Offset(40000, 0));
      await tester.pumpAndSettle();
      expect(find.text('20,0 kg', findRichText: true), findsOneWidget);
      await tester.tap(find.byKey(const Key('weight-save')));
      await tester.pumpAndSettle();
      final saved = await weights.readBetween(daysAgo(1), today);
      expect(saved.single.kg, 20);
    });

    testWidgets('each day shows the latest weigh-in up to that day', (
      tester,
    ) async {
      await weights.save(WeightEntry(day: daysAgo(13), kg: 61));
      await weights.save(WeightEntry(day: daysAgo(3), kg: 60.4));
      await pump(tester, const TodayScreen());
      expect(find.textContaining('60,4 kg'), findsOneWidget);
      final old = daysAgo(5);
      await tester.tap(find.byKey(Key('today-day-${old.month}-${old.day}')));
      await tester.pumpAndSettle();
      // The latest weigh-in on or before that day.
      expect(find.textContaining('61,0 kg'), findsOneWidget);
    });
  });

  group('Nhìn lại with every goal', () {
    Future<void> week(List<double?> kcal) async {
      for (var i = 0; i < kcal.length; i++) {
        final value = kcal[i];
        if (value != null) {
          await saveMeal(meals, 'Ngày $i', value, daysAgo(i + 1));
        }
      }
    }

    testWidgets('lose: over days, verdict and weekend gap', (tester) async {
      await week([1500, 1500, 1500, 1500, 1500, 1500, 1500]);
      // Make Saturday and Sunday of the reviewed week 1.950 kcal.
      for (var back = 1; back <= 7; back++) {
        final day = daysAgo(back);
        if (day.weekday >= DateTime.saturday) {
          await saveMeal(meals, 'Thêm cuối tuần', 450, day);
        }
      }
      await weights.save(WeightEntry(day: daysAgo(7), kg: 60.6));
      await weights.save(WeightEntry(day: daysAgo(1), kg: 60.1));
      await pump(tester, const ProgressScreen());
      expect(find.byKey(const Key('review-verdict-onTrack')), findsOneWidget);
      expect(find.text('2 ngày vượt kế hoạch'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('review-weekend')),
        200,
      );
      expect(find.text('Cuối tuần nhiều hơn 450 kcal/ngày'), findsOneWidget);
    });

    testWidgets('gain: high days never count as over; rising is on track', (
      tester,
    ) async {
      await week([3000, 3000, 3000, null, 3000, null, null]);
      await weights.save(WeightEntry(day: daysAgo(6), kg: 50));
      await weights.save(WeightEntry(day: daysAgo(2), kg: 50.3));
      await pump(
        tester,
        const ProgressScreen(),
        using: overrides(goal: GoalType.gain, target: 2500),
      );
      expect(find.byKey(const Key('review-verdict-onTrack')), findsOneWidget);
      expect(find.byKey(const Key('review-over-days')), findsNothing);
      expect(find.text('4/7'), findsOneWidget);
    });

    testWidgets('maintain: +10 % band, drift past 0,5 kg is off track', (
      tester,
    ) async {
      // Target 2.000: 2.200 is still inside the band, 2.201 is over.
      await week([2200, 2201, 2000, 1900]);
      await weights.save(WeightEntry(day: daysAgo(6), kg: 60));
      await weights.save(WeightEntry(day: daysAgo(1), kg: 60.6));
      await pump(
        tester,
        const ProgressScreen(),
        using: overrides(goal: GoalType.maintain, target: 2000),
      );
      expect(find.byKey(const Key('review-verdict-offTrack')), findsOneWidget);
      expect(find.text('1 ngày vượt kế hoạch'), findsOneWidget);
    });

    testWidgets('thin week, one weigh-in and today excluded', (tester) async {
      await week([1700, 1200]);
      await saveMeal(meals, 'Hôm nay', 5000, daysAgo(0));
      await weights.save(WeightEntry(day: daysAgo(1), kg: 60));
      await pump(tester, const ProgressScreen());
      expect(find.byKey(const Key('review-thin')), findsOneWidget);
      expect(find.text('Ghi thêm 1 ngày để xem phân tích'), findsOneWidget);
      expect(find.text('1 ngày vượt kế hoạch'), findsOneWidget);
      expect(find.text('5.000'), findsNothing);
    });

    testWidgets('exactly three days is enough; no weigh-ins stays neutral', (
      tester,
    ) async {
      await week([1500, null, 1500, null, 1500]);
      await pump(tester, const ProgressScreen());
      expect(find.byKey(const Key('review-thin')), findsNothing);
      expect(find.byKey(const Key('review-verdict-unknown')), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Chưa có gì nổi bật.'), 200);
      expect(find.text('Chưa có gì nổi bật.'), findsOneWidget);
    });
  });
}

Future<void> saveMeal(
  SqliteMealLogRepository meals,
  String name,
  double kcal,
  DateTime at,
) => meals.save(
  analysis: MealAnalysis(
    requestId: '$name-${at.microsecondsSinceEpoch}',
    items: [
      MealAnalysisItem(
        id: name,
        name: name,
        portion: null,
        nutrition: MealNutrition(caloriesKcal: kcal),
      ),
    ],
  ),
  source: MealLogSource.voice,
  portionScale: 1,
  createdAt: at,
);

/// Answers each analysis at once: queued failures first, then [next].
final class ScriptedAnalysis implements MealAnalysisRepository {
  MealAnalysis? next;
  List<MealAnalysisFailureKind> failures = [];
  final requestIds = <String>[];

  Future<MealAnalysis> _answer(String requestId) async {
    requestIds.add(requestId);
    if (failures.isNotEmpty) throw MealAnalysisFailure(failures.removeAt(0));
    final result = next!;
    return MealAnalysis(requestId: requestId, items: result.items);
  }

  @override
  Future<MealAnalysis> analyzePhoto(
    MealPhoto photo, {
    required String requestId,
    Future<void>? cancel,
  }) => _answer(requestId);

  @override
  Future<MealAnalysis> analyzeText(
    String description, {
    required String requestId,
    Future<void>? cancel,
  }) => _answer(requestId);
}

// Test data only. Each meal exercises one kind of food data.

MealAnalysisItem _item(
  String name,
  double? kcal, {
  double? protein,
  double? carbs,
  double? fat,
  MealPortion? portion,
}) => MealAnalysisItem(
  id: name,
  name: name,
  portion: portion,
  nutrition: MealNutrition(
    caloriesKcal: kcal,
    proteinGrams: protein,
    carbohydrateGrams: carbs,
    fatGrams: fat,
  ),
);

/// Two dishes with full macros: 580 kcal per portion.
MealAnalysis comGa() => MealAnalysis(
  requestId: 'com-ga',
  items: [
    _item(
      'Cơm trắng',
      200,
      protein: 4,
      carbs: 44,
      fat: 0.4,
      portion: MealPortion(amount: 180, unit: MealPortionUnit.gram),
    ),
    _item(
      'Gà xào rau',
      380,
      protein: 30,
      carbs: 20,
      fat: 18,
      portion: MealPortion(amount: 240, unit: MealPortionUnit.gram),
    ),
  ],
);

/// Known, zero and unknown kcal in one meal; no macros at all.
MealAnalysis mixedKnowledge() => MealAnalysis(
  requestId: 'mixed',
  items: [
    _item('Phở bò', 450),
    _item(
      'Trà đá',
      0,
      portion: MealPortion(amount: 250, unit: MealPortionUnit.milliliter),
    ),
    _item('Rau sống', null),
  ],
);

/// Eight dishes with long Vietnamese names: 1.385 kcal.
MealAnalysis buffet() => MealAnalysis(
  requestId: 'buffet',
  items: [
    _item('Bánh cuốn nhân thịt và mộc nhĩ chấm nước mắm chua ngọt', 300),
    _item('Chả lụa', 140),
    _item('Nem rán', 250),
    _item('Bún chả Hà Nội', 320),
    _item('Dưa góp', 25),
    _item('Chè đậu xanh nước cốt dừa', 230),
    _item('Nước sấu', 120),
    _item('Ổi', 0),
  ],
);
