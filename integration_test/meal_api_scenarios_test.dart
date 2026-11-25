import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/data/sqlite_water_log_repository.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/features/weight/data/sqlite_weight_repository.dart';
import 'package:lanh_app/features/weight/weight_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Real HTTP from the device to services/meal_api, whose model is a local
/// test stand-in that answers by keyword (see the testing notes in
/// docs/flutter/README.md). Build with
/// `--dart-define=LANH_MEAL_API_BASE_URL=http://127.0.0.1:8080`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late HttpMealAnalysisRepository api;
  setUp(() {
    final base = mealApiBaseUri();
    expect(base, isNotNull, reason: 'LANH_MEAL_API_BASE_URL');
    api = HttpMealAnalysisRepository(
      baseUri: base,
      timeout: const Duration(seconds: 30),
    );
  });

  Future<MealAnalysisFailureKind?> failureOf(Future<Object?> call) async {
    try {
      await call;
      return null;
    } on MealAnalysisFailure catch (error) {
      return error.kind;
    }
  }

  testWidgets('a clean answer keeps every number, zero included', (_) async {
    final result = await api.analyzeText('phở bò', requestId: 'clean-1');
    expect(result.items.map((i) => i.name), ['Phở bò tái', 'Trà đá']);
    expect(result.totalCalories(), 450);
    expect(result.items.last.nutrition.caloriesKcal, 0);
    expect(result.items.last.portion?.unit, MealPortionUnit.milliliter);
    expect(result.totalCalories(1.5), 675);
  });

  testWidgets('messy model data becomes unknown, never zero or negative', (
    _,
  ) async {
    final result = await api.analyzeText('don vi la', requestId: 'messy-1');
    // The nameless item and the non-object are dropped by the API.
    expect(result.items.map((i) => i.name), ['Cơm tấm sườn', 'Canh chua']);
    final com = result.items.first;
    expect(com.nutrition.caloriesKcal, 620); // from "620kcal"
    expect(com.nutrition.proteinGrams, isNull); // from -5
    expect(com.nutrition.carbohydrateGrams, isNull); // from "NaN"
    expect(com.portion, isNull); // "bowl" is not a known unit
    final canh = result.items.last;
    expect(canh.nutrition.caloriesKcal, isNull);
    expect(result.totalCalories(), 620);
    expect(result.itemsMissingCalories, 1);
  });

  testWidgets('no food, broken model output and empty input fail clearly', (
    _,
  ) async {
    expect(
      await failureOf(api.analyzeText('khong co mon', requestId: 'none-1')),
      MealAnalysisFailureKind.noFood,
    );
    expect(
      await failureOf(api.analyzeText('json hong', requestId: 'broken-1')),
      MealAnalysisFailureKind.noFood,
    );
    // Blank text never leaves the device: the client rejects it up front
    // (the send action is disabled for it too).
    expect(
      () => api.analyzeText('   ', requestId: 'empty-1'),
      throwsArgumentError,
    );
  });

  testWidgets('a photo goes through the same API', (_) async {
    final bytes = await rootBundle.load(
      'assets/design/images/dzdAuAChai1.jpeg',
    );
    final result = await api.analyzePhoto(
      MealPhoto(bytes.buffer.asUint8List()),
      requestId: 'photo-1',
    );
    expect(result.totalCalories(), 450);
  });

  testWidgets('an unreachable server is a network failure', (_) async {
    final down = HttpMealAnalysisRepository(
      baseUri: mealApiBaseUri()!.replace(port: 9),
      timeout: const Duration(seconds: 10),
    );
    expect(
      await failureOf(down.analyzeText('phở', requestId: 'down-1')),
      MealAnalysisFailureKind.network,
    );
  });

  testWidgets('messy data saves and shows on Home with only known kcal', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('lanh_api');
    addTearDown(() => dir.delete(recursive: true));
    final meals = SqliteMealLogRepository(databasePath: '${dir.path}/m.db');
    final result = await api.analyzeText('don vi la', requestId: 'save-1');
    await meals.save(
      analysis: result,
      source: MealLogSource.voice,
      portionScale: 0.5,
    );
    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileGoalProvider.overrideWithValue(
            AsyncData(
              Goal(type: GoalType.lose, createdAt: now, updatedAt: now),
            ),
          ),
          profileEnergyTargetProvider.overrideWithValue(1600),
          waterGoalGlassesProvider.overrideWithValue(8),
          mealLogRepositoryProvider.overrideWithValue(meals),
          waterLogRepositoryProvider.overrideWithValue(
            SqliteWaterLogRepository(databasePath: '${dir.path}/w.db'),
          ),
          weightRepositoryProvider.overrideWithValue(
            SqliteWeightRepository(databasePath: '${dir.path}/k.db'),
          ),
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
          home: const AppBackground(child: TodayScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Half a portion of 620 known kcal; the unknown dish adds nothing.
    expect(find.text('Cơm tấm sườn, Canh chua'), findsOneWidget);
    expect(find.text('310 kcal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
