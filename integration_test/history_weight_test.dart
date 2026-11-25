import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
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

/// History by day, weigh-ins, meal delete and Nhìn lại on a device, with
/// the real SQLite repositories in a throwaway folder (never the user's
/// databases).
/// Seconds to keep a finished screen on the device for a manual look,
/// e.g. `--dart-define=LANH_DEVICE_HOLD_SECONDS=20`. Zero by default.
const _holdSeconds = int.fromEnvironment('LANH_DEVICE_HOLD_SECONDS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> hold(WidgetTester tester) async {
    if (_holdSeconds <= 0) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: _holdSeconds)),
    );
    await tester.pump();
  }

  late Directory dir;
  late SqliteMealLogRepository meals;
  late SqliteWaterLogRepository water;
  late SqliteWeightRepository weights;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int n, [int hour = 12]) =>
      DateTime(today.year, today.month, today.day - n, hour);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lanh_history');
    meals = SqliteMealLogRepository(databasePath: '${dir.path}/meals.db');
    water = SqliteWaterLogRepository(databasePath: '${dir.path}/water.db');
    weights = SqliteWeightRepository(databasePath: '${dir.path}/weight.db');
  });
  tearDown(() => dir.delete(recursive: true));

  Future<MealLog> logMeal(
    String name,
    double kcal,
    DateTime at, {
    MealPhoto? photo,
  }) => meals.save(
    analysis: MealAnalysis(
      requestId: '$name-${at.millisecondsSinceEpoch}',
      items: [
        MealAnalysisItem(
          id: name,
          name: name,
          portion: null,
          nutrition: MealNutrition(
            caloriesKcal: kcal,
            proteinGrams: 25,
            carbohydrateGrams: 70,
            fatGrams: 12,
          ),
        ),
      ],
    ),
    source: MealLogSource.voice,
    portionScale: 1,
    photo: photo,
    createdAt: at,
  );

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          profileGoalProvider.overrideWithValue(
            AsyncData(
              Goal(
                type: GoalType.lose,
                currentWeight: 53,
                createdAt: daysAgo(30),
                updatedAt: daysAgo(30),
              ),
            ),
          ),
          profileEnergyTargetProvider.overrideWithValue(1600),
          waterGoalGlassesProvider.overrideWithValue(8),
          mealLogRepositoryProvider.overrideWithValue(meals),
          waterLogRepositoryProvider.overrideWithValue(water),
          weightRepositoryProvider.overrideWithValue(weights),
        ],
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

  Finder day(DateTime value) =>
      find.byKey(Key('today-day-${value.month}-${value.day}'));

  testWidgets('Home by day: past days are read-only, today can log', (
    tester,
  ) async {
    await logMeal('Cơm tấm sườn', 620, daysAgo(1));
    await logMeal('Phở bò', 450, daysAgo(0, 7));
    await water.add(at: daysAgo(1, 9), milliliters: 250);
    await water.add(at: daysAgo(1, 10), milliliters: 250);
    await pump(tester, const TodayScreen());

    expect(find.text('Phở bò'), findsOneWidget);
    await tester.tap(day(daysAgo(1)));
    await tester.pumpAndSettle();
    expect(find.text('Cơm tấm sườn'), findsOneWidget);
    expect(find.text('500 / 2.000 ml'), findsOneWidget);
    expect(find.byKey(const Key('today-weight-update')), findsNothing);
    await tester.tap(find.byKey(const Key('today-water-glass-5')));
    await tester.pumpAndSettle();
    expect(await water.countForDate(daysAgo(1)), 2);
    expect(await water.countForDate(today), 0);

    await tester.tap(day(daysAgo(4)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-empty-day')), findsOneWidget);

    await tester.tap(find.byKey(const Key('today-back-to-today')));
    await tester.pumpAndSettle();
    expect(find.text('Phở bò'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-water-glass-0')));
    await tester.pumpAndSettle();
    expect(await water.countForDate(today), 1);
  });

  testWidgets('weigh-ins persist one per day in SQLite', (tester) async {
    await pump(tester, const TodayScreen());
    expect(find.textContaining('53,0 kg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-minus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-save')));
    await tester.pumpAndSettle();
    expect(find.text('52,9 kg · hôm nay'), findsOneWidget);

    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weight-sheet-replace')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('weight-input')), '301');
    await tester.pumpAndSettle();
    expect(find.text('Nhập từ 20 đến 300 kg'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('weight-input')), '52,7');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-save')));
    await tester.pumpAndSettle();
    final saved = await weights.readBetween(daysAgo(30), today);
    expect(saved.single.kg, 52.7);
    expect(saved.single.day, today);

    await tester.tap(find.byKey(const Key('today-weight-update')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-delete')));
    await tester.pumpAndSettle();
    expect(await weights.readBetween(daysAgo(30), today), isEmpty);
    expect(find.textContaining('53,0 kg'), findsOneWidget);
  });

  testWidgets('deleting a meal removes its row and its photo file', (
    tester,
  ) async {
    final bytes = await rootBundle.load(
      'assets/design/images/dzdAuAChai1.jpeg',
    );
    final saved = await logMeal(
      'Cơm gà xào rau',
      580,
      daysAgo(0, 8),
      photo: MealPhoto(bytes.buffer.asUint8List()),
    );
    expect(File(saved.imagePath!).existsSync(), isTrue);
    await pump(tester, const TodayScreen());

    await tester.tap(find.text('Cơm gà xào rau'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-detail-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-delete-confirm')));
    await tester.pumpAndSettle();

    expect(await meals.readForDate(today), isEmpty);
    expect(File(saved.imagePath!).existsSync(), isFalse);
    expect(find.byKey(const Key('today-first-meal')), findsOneWidget);
  });

  testWidgets('Nhìn lại reads the seven days before today', (tester) async {
    for (var back = 1; back <= 7; back++) {
      final weekday = daysAgo(back).weekday;
      final weekend =
          weekday == DateTime.saturday || weekday == DateTime.sunday;
      await logMeal('Bữa $back', weekend ? 1950 : 1500, daysAgo(back));
    }
    await logMeal('Hôm nay', 2500, daysAgo(0)); // outside the review
    await weights.save(WeightEntry(day: daysAgo(7), kg: 53.1));
    await weights.save(WeightEntry(day: daysAgo(1), kg: 52.8));
    for (var glass = 0; glass < 8; glass++) {
      await water.add(at: daysAgo(2, 8 + glass), milliliters: 250);
    }
    await pump(tester, const ProgressScreen());

    expect(find.byKey(const Key('review-verdict-onTrack')), findsOneWidget);
    expect(find.text('7/7'), findsOneWidget);
    expect(find.text('2 lần cân'), findsOneWidget);
    expect(find.text('1/1 ngày đủ ly'), findsOneWidget);
    expect(find.text('2 ngày vượt kế hoạch'), findsOneWidget);
    await hold(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-weekend')),
      200,
    );
    expect(find.text('Cuối tuần nhiều hơn 450 kcal/ngày'), findsOneWidget);
    await hold(tester);
  });
}
