import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/meal_logging/data/fake_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_flow.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/test_goal_repository.dart';
import '../test/support/test_profile_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fake analysis saves a meal and persists it in SQLite', (
    tester,
  ) async {
    final bytes = await rootBundle.load(
      'assets/design/images/dzdAuAChai1.jpeg',
    );
    final photo = MealPhoto(bytes.buffer.asUint8List());
    final repository = SqliteMealLogRepository();
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          mealAnalysisRepositoryProvider.overrideWithValue(
            FakeMealAnalysisRepository(),
          ),
          mealLogRepositoryProvider.overrideWithValue(repository),
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
          home: AppBackground(child: MealPhotoFlow(recoveredPhoto: photo)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-photo-estimate')));
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra bữa ăn'), findsOneWidget);

    await tester.tap(find.byKey(const Key('meal-analysis-save')));
    await tester.tap(find.byKey(const Key('meal-analysis-save')));
    await tester.pumpAndSettle();

    final saved = await repository.readForDate(DateTime.now());
    expect(saved, isNotEmpty);
    final meal = saved.first;
    expect(meal.source.name, 'photo');
    expect(meal.items, isNotEmpty);
    expect(meal.imagePath, isNotNull);
    expect(File(meal.imagePath!).existsSync(), isTrue);

    final yesterdayAnalysis = await FakeMealAnalysisRepository().analyzeText(
      'yesterday',
      requestId: 'yesterday-request',
    );
    await repository.save(
      analysis: yesterdayAnalysis,
      source: MealLogSource.voice,
      portionScale: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    final todayOnly = await repository.readForDate(DateTime.now());
    expect(
      todayOnly.every((entry) => entry.requestId != 'yesterday-request'),
      isTrue,
    );

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          mealLogRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
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
    expect(find.text('Cơm trắng, Cá hồi áp chảo'), findsOneWidget);
    expect(find.text('484 kcal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
