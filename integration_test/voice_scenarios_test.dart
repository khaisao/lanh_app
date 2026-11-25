import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_voice_recognizer.dart';
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

/// Spoken meals end to end on a simulator, which has no usable microphone:
/// a scripted recognizer "speaks" (partial words, the final sentence,
/// silence, errors), then the real HTTP client calls services/meal_api and
/// the meal lands in SQLite and on Home. Build with
/// `--dart-define=LANH_MEAL_API_BASE_URL=http://127.0.0.1:8080`; the API's
/// model is a local stand-in that answers by keyword.
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
              timeout: const Duration(seconds: 30),
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
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('meal-analysis-result')).evaluate().isNotEmpty ||
          find.text('Chưa ước lượng được').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();
  }

  testWidgets('spoken meal is estimated, saved and shown on Home', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['Ăn', 'một', 'tô', 'phở', 'bò', 'và', 'trà', 'đá']);
    expect(find.text('Ăn một tô phở bò và trà đá'), findsOneWidget);
    await send(tester);
    expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-analysis-save')));
    await tester.pumpAndSettle();

    final saved = (await meals.readForDate(today)).single;
    expect(saved.source, MealLogSource.voice);
    expect(saved.totalCalories, 450);
    expect(saved.imagePath, isNull);
    expect(find.text('Phở bò tái, Trà đá'), findsOneWidget);
    expect(find.text('450 kcal'), findsOneWidget);
  });

  testWidgets('an edited transcript is what gets sent and saved', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['phở', 'bò']);
    // The person corrects the words before sending: messy model data.
    await tester.enterText(
      find.byKey(const Key('meal-voice-text')),
      'cơm tấm don vi la',
    );
    await tester.pump();
    await send(tester);
    await tester.tap(find.byKey(const Key('meal-analysis-save')));
    await tester.pumpAndSettle();
    final saved = (await meals.readForDate(today)).single;
    expect(saved.names, ['Cơm tấm sườn', 'Canh chua']);
    expect(saved.totalCalories, 620); // the unknown dish adds nothing
  });

  testWidgets('a meal the API cannot find keeps the words; nothing saved', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    await speak(tester, ['khong', 'co', 'mon']);
    await send(tester);
    expect(find.text('Chưa ước lượng được'), findsOneWidget);
    expect(find.textContaining('Lời kể vẫn được giữ lại'), findsOneWidget);
    expect(await meals.readForDate(today), isEmpty);
  });

  testWidgets('silence and recognizer errors explain and allow a retry', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    voice.fail(MealVoiceFailureKind.noSpeech);
    await voice.finish();
    await tester.pumpAndSettle();
    expect(
      find.text('Lành chưa nghe thấy lời nào. Chạm micro và kể lại nhé.'),
      findsOneWidget,
    );
    // Talk again after the silence, then the recognizer breaks.
    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pumpAndSettle();
    expect(voice.languages, ['vi', 'vi']);
    voice.fail(MealVoiceFailureKind.recognition);
    await voice.finish();
    await tester.pumpAndSettle();
    // No words: a recognition error explains itself on the microphone.
    expect(find.byKey(const Key('meal-voice-message')), findsOneWidget);
    expect(find.text('Chạm để bắt đầu nói'), findsOneWidget);

    // Words heard before a late error are kept for checking.
    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pumpAndSettle();
    voice.hear('phở bò');
    await tester.pump();
    voice.fail(MealVoiceFailureKind.recognition);
    await voice.finish();
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra lời nói'), findsOneWidget);
    expect(find.text('phở bò'), findsOneWidget);
    expect(await meals.readForDate(today), isEmpty);
  });

  testWidgets('cancelling while speaking returns Home with nothing saved', (
    tester,
  ) async {
    await openHome(tester);
    await startRecording(tester);
    voice.hear('Ăn một bát');
    await tester.pump();
    await tester.tap(find.byKey(const Key('meal-voice-cancel')));
    await tester.pumpAndSettle();
    expect(voice.cancels, greaterThan(0));
    expect(find.byKey(const Key('today-first-meal')), findsOneWidget);
    expect(await meals.readForDate(today), isEmpty);
  });
}
