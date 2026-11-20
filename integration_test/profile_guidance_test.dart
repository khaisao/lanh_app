import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart'
    show mealLogRepositoryProvider;
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:lanh_app/features/profile_setup/domain/profile.dart';

import '../test/support/test_goal_repository.dart';
import '../test/support/test_meal_log_repository.dart';
import '../test/support/test_onboarding_repository.dart';
import '../test/support/test_profile_repository.dart';

/// Device check for Profile Setup: liquid glass cards, the WHO Asian BMI
/// reading, activity energy before the target, Lành's 5%/10% plans with kcal,
/// the review kcal choice and the teen path. Uses an in-memory repository, so
/// nothing is written to the device profile. Screenshots and `results.json`
/// land in the app's `tmp/profile-setup` folder.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final artifacts = Directory('${Directory.systemTemp.path}/profile-setup');
  // Keep readable failure text: the binding only stores a type name.
  final errors = <String, String>{};
  final report = reportTestException;
  reportTestException = (details, description) {
    errors[description] = "${details.exceptionAsString()}\n${details.stack}";
    report(details, description);
  };
  tearDownAll(() async {
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/results.json').writeAsString(
      jsonEncode({
        'runId': const String.fromEnvironment('LANH_DEVICE_RUN_ID'),
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
        'passed':
            binding.results.isNotEmpty && binding.failureMethodsDetails.isEmpty,
        'results': binding.results.map(
          (name, result) => MapEntry(name, '$result'),
        ),
        'errors': errors,
        'platform': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
      }),
    );
  });

  const captureKey = Key('profile-capture');

  // Renders the app layer in-process, so captures work on a device run that
  // has no attached driver (e.g. a Profile build launched by devicectl).
  Future<void> screenshot(
    WidgetTester tester,
    String name, {
    bool settle = true,
  }) async {
    if (settle) await tester.pump(const Duration(milliseconds: 400));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final ratio = tester.view.devicePixelRatio;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await artifacts.create(recursive: true);
      await File('${artifacts.path}/$name.png')
          .writeAsBytes(png!.buffer.asUint8List());
    });
  }

  Future<void> mount(WidgetTester tester, {bool motion = false}) async {
    // The mascot bounce loops forever; Reduce Motion lets pumpAndSettle end.
    // With motion on, callers pump fixed durations instead.
    if (!motion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
        ],
        child: RepaintBoundary(
          key: captureKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: const AppBackground(child: ProfileSetupScreen()),
          ),
        ),
      ),
    );
    if (motion) {
      await tester.pump(const Duration(seconds: 1));
    } else {
      await tester.pumpAndSettle();
    }
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // The device IME echoes its own state over tester.enterText, so set the
  // controller and fire onChanged, which is what typing does.
  Future<void> enter(WidgetTester tester, String key, String value) async {
    final finder = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(finder);
    final field = tester.widget<TextField>(finder);
    field.controller!.text = value;
    field.onChanged!(value);
    await tester.pumpAndSettle();
  }

  Future<void> fillBody(
    WidgetTester tester, {
    required String age,
    required String height,
    required String weight,
  }) async {
    await enter(tester, 'profile-age', age);
    await enter(tester, 'profile-height', height);
    await enter(tester, 'profile-current-weight', weight);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const Key('profile-sex-female')));
  }

  final action = find.byKey(const Key('profile-setup-action'));

  testWidgets('adult loss: glass goal, BMI and Lành plans', (tester) async {
    await mount(tester);
    await tap(tester, find.text('Giảm cân'));
    await screenshot(tester, '1-goal');
    await tap(tester, action);

    await fillBody(tester, age: '32', height: '165', weight: '61,5');
    await screenshot(tester, '2a-body-filled');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    // 61.5 kg / 1.65² = 22.6: normal on the WHO Asian scale (18.5–22.9).
    expect(find.text('22,6'), findsOneWidget);
    expect(find.text('Trong khoảng thường gặp'), findsOneWidget);
    expect(
      find.text('Theo ngưỡng WHO cho người châu Á: bình thường 18,5–22,9.'),
      findsOneWidget,
    );
    await screenshot(tester, '2-body');
    await tap(tester, action);

    // Activity now comes first: 1,325 kcal resting × PAL 1.40 ≈ 1,855.
    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
    await tap(tester, find.byKey(const Key('profile-activity-sitting')));
    expect(find.text('1.850'), findsOneWidget);
    await screenshot(tester, '3-activity');
    await tap(tester, action);

    // 5% → 58 kg, 7% → 57 kg, 10% → 55 kg, all above BMI 18.5 (50.4 kg).
    expect(find.text('58 kg'), findsOneWidget);
    expect(find.text('55 kg'), findsOneWidget);
    expect(find.text('57 kg'), findsOneWidget);
    // Gentle pace 0.24 kg/week: 1,855 − 260 ≈ 1,595 kcal/day, spoken with
    // the plan.
    expect(
      tester.getSemantics(find.byKey(const Key('profile-target-plan-0'))).label,
      contains('≈ 1.600 kcal/ngày'),
    );
    await screenshot(tester, '4-target-suggested');

    // Custom: starts at the chosen 58 kg plan, gentle pace, no date.
    await tap(tester, find.text('Tự chọn'));
    expect(find.byKey(const Key('profile-target-slider')), findsOneWidget);
    await screenshot(tester, '5-target-custom');

    // The switch opens the picker at the earliest safe date.
    final toggle = find.byKey(const Key('profile-target-date-switch'));
    await tap(tester, toggle);
    final labels = MaterialLocalizations.of(
      tester.element(find.byType(DatePickerDialog)),
    );
    await screenshot(tester, '5a-date-picker');
    await tap(tester, find.text(labels.okButtonLabel));
    expect(find.byKey(const Key('profile-target-date')), findsOneWidget);
    await screenshot(tester, '5b-target-custom-date');

    // A lower target needs longer: the date moves and Lành says so.
    for (var step = 0; step < 6; step++) {
      await tap(tester, find.byKey(const Key('profile-target-decrease')));
    }
    expect(find.byKey(const Key('profile-target-date-moved')), findsOneWidget);
    await screenshot(tester, '5c-target-date-moved');

    // Back to 58 kg without a date for the plan sheet below.
    for (var step = 0; step < 6; step++) {
      await tap(tester, find.byKey(const Key('profile-target-increase')));
    }
    await tap(tester, toggle);
    expect(find.byKey(const Key('profile-target-date')), findsNothing);
    await tap(tester, action);
    // Plan sheet: 1,855 − 260 ≈ 1.600 kcal; body ~1.850; cut 250.
    expect(find.byKey(const Key('profile-plan-sheet')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('profile-plan-kcal'))).data,
      '1.600',
    );
    expect(find.text('Bớt 250'), findsOneWidget);
    await screenshot(tester, '6-plan-lose');
    expect(tester.takeException(), isNull);
  });

  testWidgets('teen path skips the numeric target', (tester) async {
    await mount(tester);
    await tap(tester, find.text('Giảm cân'));
    await tap(tester, action);
    await fillBody(tester, age: '13', height: '160', weight: '42');
    await tap(tester, action);

    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
    expect(find.text('Mục tiêu an toàn trong giai đoạn lớn'), findsOneWidget);
    expect(find.byKey(const Key('profile-energy-estimate')), findsNothing);
    await screenshot(tester, '7-teen-activity');
    await tap(tester, find.byKey(const Key('profile-activity-sitting')));
    await tap(tester, action);
    // Teens: review without a kcal number or a numeric target.
    expect(find.byKey(const Key('profile-plan-no-kcal')), findsOneWidget);
    expect(find.byKey(const Key('profile-plan-budget')), findsNothing);
    expect(find.byKey(const Key('profile-target-slider')), findsNothing);
    await screenshot(tester, '8-teen-plan');
    expect(tester.takeException(), isNull);
  });

  testWidgets('BMI card reveal frames with motion on', (tester) async {
    const step = Duration(milliseconds: 600);
    await mount(tester, motion: true);
    await tester.tap(find.text('Giảm cân'));
    await tester.pump(step);
    await tester.tap(action);
    await tester.pump(step);
    // Continue with nothing filled: short "enter it" hints.
    await tester.tap(action);
    await tester.pump(step);
    expect(find.text('Nhập tuổi của bạn'), findsOneWidget);
    await screenshot(tester, '9-body-empty-hints', settle: false);
    for (final (key, value) in [
      ('profile-age', '32'),
      ('profile-height', '165'),
      ('profile-current-weight', '61,5'),
    ]) {
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ),
      );
      field.controller!.text = value;
      field.onChanged!(value);
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Male is preselected, so the last number completes the input: debounce,
    // then the grow-in and ring sweep.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(AppMotion.bmiShowDelay);
    // Six frames, 150 ms apart, across the 480 ms open and 1.1 s sweep.
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 150));
      await screenshot(tester, '9-bmi-frame-$frame', settle: false);
    }
    final female = find.byKey(const Key('profile-sex-female'));
    await tester.ensureVisible(female);
    await tester.pump(step);
    await tester.tap(female);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('22,6'), findsOneWidget);
    await screenshot(tester, '9-bmi-reveal-done', settle: false);

    // Step change: the body slides out, Activity slides in and its tiles
    // rise one after another while the progress fill grows.
    Future<void> frames(String name, {int count = 4, int ms = 90}) async {
      for (var frame = 0; frame < count; frame++) {
        await tester.pump(Duration(milliseconds: ms));
        await screenshot(tester, '$name-$frame', settle: false);
      }
    }

    await tester.tap(action);
    await frames('10-step-switch');
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);

    // Choosing a tile: outline and icon well fill, check pops, card pops.
    await tester.tap(find.byKey(const Key('profile-activity-sitting')));
    await frames('11-select-activity', count: 3, ms: 110);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1.850'), findsOneWidget);
    await tester.tap(action);
    await tester.pump(const Duration(seconds: 2));

    // Choosing the 7% plan: the card fills with primary and pops.
    final plan = find.byKey(const Key('profile-target-plan-1'));
    await tester.ensureVisible(plan);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(plan);
    await frames('12-select-plan', count: 3, ms: 110);
    await tester.pump(const Duration(seconds: 1));
    await screenshot(tester, '12-select-plan-done', settle: false);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plan sheet: gain and maintain variants', (tester) async {
    await mount(tester);
    await tap(tester, find.text('Tăng cân'));
    await tap(tester, action);
    await enter(tester, 'profile-age', '25');
    await enter(tester, 'profile-height', '175');
    await enter(tester, 'profile-current-weight', '58');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tap(tester, action);
    await tap(tester, find.byKey(const Key('profile-activity-light')));
    await tap(tester, action);
    await tap(tester, action);
    // Male default, 2,408 kcal used → 2.400; +150 → 2.550.
    expect(find.text('2.550'), findsOneWidget);
    expect(find.text('Thêm 150'), findsOneWidget);
    await screenshot(tester, '13-plan-gain');
    await tap(tester, find.byKey(const Key('profile-plan-edit')));
    expect(find.byKey(const Key('profile-plan-sheet')), findsNothing);

    // Back to the goal step and switch to Maintain.
    for (var step = 0; step < 3; step++) {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
    await tap(tester, find.text('Giữ cân'));
    await tap(tester, action);
    await tap(tester, action);
    await tap(tester, action);
    expect(find.text('Bằng mức cơ thể dùng'), findsOneWidget);
    await screenshot(tester, '14-plan-maintain');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today first run after the plan', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final now = DateTime.now();
    final profiles = TestProfileRepository()
      ..profile = Profile(
        ageYears: 32,
        heightCm: 165,
        sex: ProfileSex.female,
        activityLevel: ActivityLevel.sitting,
        dailyEnergyKcal: 1600,
        goal: Goal(
          type: GoalType.lose,
          currentWeight: 61.5,
          targetWeight: 58,
          createdAt: now,
          updatedAt: now,
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            TestOnboardingRepository()..completed = true,
          ),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
          mealLogRepositoryProvider.overrideWithValue(TestMealLogRepository()),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const RepaintBoundary(key: captureKey, child: Application()),
      ),
    );
    // Startup reads onboarding and the profile asynchronously.
    for (var tick = 0; tick < 100; tick++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('/ 1.600 kcal').evaluate().isNotEmpty) break;
    }
    expect(find.text('/ 1.600 kcal'), findsOneWidget);
    expect(find.text('Còn 1.600 kcal'), findsOneWidget);
    expect(find.byKey(const Key('today-first-meal')), findsOneWidget);
    await screenshot(tester, '15-today-first-run');
    expect(tester.takeException(), isNull);
  });
}
