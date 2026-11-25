import 'package:app_ui/app_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_method_sheet.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_voice_flow.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/test_meal_analysis_repository.dart';
import '../test/support/test_meal_voice_recognizer.dart';
import '../test/support/test_profile_repository.dart';

/// Exercises production widgets on Android. Only speech input and analysis
/// are scripted so the visual check needs no microphone or remote server.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shared navigation and revised voice confirmation on Android', (
    tester,
  ) async {
    final voice = TestMealVoiceRecognizer();
    final analysis = TestMealAnalysisRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealVoiceRecognizerProvider.overrideWithValue(voice),
          mealAnalysisRepositoryProvider.overrideWithValue(analysis),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Builder(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppButton(
                            label: 'Voice',
                            onPressed: () => showMealVoiceFlow(context),
                          ),
                          AppButton(
                            label: 'Methods',
                            onPressed: () => showMealMethodSheet(context),
                          ),
                          AppButton(
                            label: 'Profile',
                            onPressed: () => context.push('/profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const AppBackground(child: ProfileSetupScreen()),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();

    Future<void> shot(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      await binding.takeScreenshot(name);
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Methods'));
    await tester.pumpAndSettle();
    await shot('android-meal-method-close');
    await tester.tap(find.byKey(const Key('close-meal-sheet')));
    await tester.pumpAndSettle();
    expect(find.text('Methods'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await shot('android-profile-back');
    await tester.tap(find.byType(AppNavigationButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voice'));
    await tester.pump(const Duration(seconds: 1));
    await shot('android-voice-close');
    voice.hear('Ăn một tô phở bò tái, thêm ly trà đá', isFinal: true);
    await voice.finish();
    await tester.pumpAndSettle();
    expect(find.text('Lành nghe rồi'), findsOneWidget);
    await shot('android-voice-confirm');

    await tester.tap(find.byKey(const Key('meal-voice-text')));
    await tester.showKeyboard(find.byKey(const Key('meal-voice-text')));
    for (
      var frame = 0;
      frame < 20 && tester.view.viewInsets.bottom == 0;
      frame++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // A simulator with the Mac keyboard attached never shows the on-screen
    // one; stand in its height so the layout check still runs.
    if (tester.view.viewInsets.bottom == 0) {
      tester.view.viewInsets = FakeViewPadding(
        bottom: 336 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetViewInsets);
    }
    expect(tester.view.viewInsets.bottom, greaterThan(0));
    await tester.pumpAndSettle();
    await shot('android-voice-confirm-keyboard');
    expect(
      find.byKey(const Key('meal-voice-send')).hitTestable(),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('meal-voice-text')),
      'Ăn một tô phở bò tái',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await tester.pump(const Duration(seconds: 1));
    expect(analysis.descriptions, ['Ăn một tô phở bò tái']);
    await shot('android-estimation-back');
    analysis.succeed();
    await tester.pumpAndSettle();
    await shot('android-meal-review-back-close');
    await tester.tap(find.byKey(const Key('meal-analysis-back')));
    await tester.pumpAndSettle();
    expect(find.text('Ăn một tô phở bò tái'), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-voice-record-again')));
    await tester.pump(const Duration(seconds: 1));
    expect(voice.listening, isTrue);
    await tester.tap(find.byKey(const Key('meal-voice-close')));
    await tester.pumpAndSettle();
    expect(find.text('Voice'), findsOneWidget);
  });
}
