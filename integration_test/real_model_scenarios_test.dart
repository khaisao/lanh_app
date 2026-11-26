import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/today/presentation/today_screen.dart';
import 'package:lanh_app/features/water/data/sqlite_water_log_repository.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/features/weight/data/sqlite_weight_repository.dart';
import 'package:lanh_app/features/weight/weight_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/test_meal_voice_recognizer.dart';

/// Release check against the REAL local model: services/meal_api calling
/// Ollama Gemma on this Mac. Answers vary, so checks use plausible ranges and
/// invariants (saved total equals the shown total, nothing saved on failure)
/// rather than exact numbers. A scripted recognizer stands in for the
/// simulator's microphone. Build with
/// `--dart-define=LANH_MEAL_API_BASE_URL=http://127.0.0.1:8080`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late SqliteMealLogRepository meals;
  late TestMealVoiceRecognizer voice;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  setUp(() async {
    expect(mealApiBaseUri(), isNotNull, reason: 'LANH_MEAL_API_BASE_URL');
    dir = await Directory.systemTemp.createTemp('lanh_voice');
    meals = SqliteMealLogRepository(databasePath: '${dir.path}/meals.db');
    voice = TestMealVoiceRecognizer();
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> openHome(WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          profileGoalProvider.overrideWithValue(
            AsyncData(
              Goal(type: GoalType.lose, createdAt: now, updatedAt: now),
            ),
          ),
          profileEnergyTargetProvider.overrideWithValue(1600),
          waterGoalGlassesProvider.overrideWithValue(8),
          mealLogRepositoryProvider.overrideWithValue(meals),
          mealVoiceRecognizerProvider.overrideWithValue(voice),
          mealAnalysisRepositoryProvider.overrideWithValue(
            HttpMealAnalysisRepository(
              baseUri: mealApiBaseUri(),
              timeout: const Duration(seconds: 90),
            ),
          ),
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
  }

  /// Home's first-meal action → picker → "Ghi bằng giọng nói".
  Future<void> startRecording(WidgetTester tester) async {
    final action = find.byKey(const Key('today-first-meal-action'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-method-voice')));
    await tester.pumpAndSettle();
    expect(voice.listening, isTrue);
    expect(find.text('Đang ghi âm'), findsOneWidget);
  }

  /// Simulated speech: words arrive as the person talks, then the
  /// recognizer settles on the final sentence after "stop".
  Future<void> speak(WidgetTester tester, List<String> words) async {
    for (var i = 0; i < words.length; i++) {
      voice.level(0.4 + i * 0.1);
      voice.hear(words.sublist(0, i + 1).join(' '));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pump();
    voice.hear(words.join(' '), isFinal: true);
    await voice.finish();
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra lời nói'), findsOneWidget);
  }

  /// Sends the confirmed text and waits for the API answer.
  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    for (var i = 0; i < 1000; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('meal-analysis-result')).evaluate().isNotEmpty ||
          find.text('Chưa ước lượng được').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
  }

  /// Saves the estimate and checks the stored total against [min]..[max].
  Future<void> saveAndCheck(
    WidgetTester tester, {
    required int min,
    required int max,
  }) async {
    expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-analysis-save')));
    await tester.pumpAndSettle();
    final saved = (await meals.readForDate(today)).single;
    expect(saved.source, MealLogSource.voice);
    final kcal = saved.totalCalories;
    expect(kcal, isNotNull);
    expect(kcal!, inInclusiveRange(min, max), reason: saved.names.join(', '));
    expect(saved.names, isNotEmpty);
    for (final name in saved.names) {
      expect(name.trim(), isNotEmpty);
    }
    // Home shows exactly what was saved.
    final shown = NumberFormat.decimalPattern('vi').format(kcal.round());
    expect(find.textContaining('$shown kcal'), findsWidgets);
    debugPrint('REAL ${saved.names} -> $kcal kcal');
  }

  testWidgets('real model: one dish is estimated, saved and shown', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['một', 'tô', 'phở', 'bò']);
    await send(tester);
    await saveAndCheck(tester, min: 250, max: 900);
  });

  testWidgets('real model: a mixed meal keeps every dish', (tester) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['cơm', 'tấm', 'sườn', 'và', 'một', 'ly', 'trà', 'đá']);
    await send(tester);
    await saveAndCheck(tester, min: 400, max: 1400);
    expect(
      (await meals.readForDate(today)).single.names.length,
      greaterThanOrEqualTo(2),
    );
  });

  testWidgets('real model: the half-portion choice halves the saved total', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['một', 'đĩa', 'cơm', 'rang', 'dưa', 'bò']);
    await send(tester);
    expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
    final half = find.byKey(const Key('meal-portion-0.5'));
    await tester.ensureVisible(half);
    await tester.pumpAndSettle();
    await tester.tap(half);
    await tester.pumpAndSettle();
    await saveAndCheck(tester, min: 150, max: 700);
    final saved = (await meals.readForDate(today)).single;
    expect(saved.portionScale, 0.5);
  });

  for (final words in [
    ['cái', 'bàn', 'gỗ', 'và', 'ghế', 'nhựa'],
    ['asdkjh', 'qwe', 'zzz'],
  ]) {
    testWidgets('real model: "${words.join(' ')}" is not food; nothing saved', (
      tester,
    ) async {
      await openHome(tester);
      await startRecording(tester);
      await speak(tester, words);
      await send(tester);
      expect(find.text('Chưa ước lượng được'), findsOneWidget);
      expect(find.textContaining('Lời kể vẫn được giữ lại'), findsOneWidget);
      expect(await meals.readForDate(today), isEmpty);
    });
  }
}
