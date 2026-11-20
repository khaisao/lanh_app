import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:app_ui/app_ui.dart' show AppBottomBar, AppRollingText;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart'
    show mealLogRepositoryProvider;
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:material_ui/material_ui.dart'
    show DatePickerDialog, FilledButton, Icon, MaterialLocalizations, Slider;

import 'support/test_goal_repository.dart';
import 'support/test_meal_log_repository.dart';
import 'support/test_onboarding_repository.dart';
import 'support/test_profile_repository.dart';

void main() {
  void reduceMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  Future<void> tapText(WidgetTester tester, String label) async {
    final target = find.text(label);
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(target, 120);
    }
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  const goalAction = 'Đặt mục tiêu của tôi';
  const setupActionKey = Key('profile-setup-action');

  Future<void> tapSetupAction(WidgetTester tester) async {
    await tester.tap(find.byKey(setupActionKey));
    await tester.pumpAndSettle();
  }

  Future<void> enterProfileValue(
    WidgetTester tester,
    String field,
    String value,
  ) async {
    final input = find.descendant(
      of: find.byKey(Key('profile-$field')),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(input);
    await tester.enterText(input, value);
    await tester.pumpAndSettle();
  }

  Future<void> fillBody(WidgetTester tester, {String weight = '62,5'}) async {
    await enterProfileValue(tester, 'age', '32');
    await enterProfileValue(tester, 'height', '160');
    await enterProfileValue(tester, 'current-weight', weight);
    await tapText(tester, 'Nữ');
    await tapSetupAction(tester);
  }

  /// Moves the custom target slider to [kg].
  Future<void> setCustomKg(WidgetTester tester, double kg) async {
    tester
        .widget<Slider>(find.byKey(const Key('profile-target-slider')))
        .onChanged!(kg);
    await tester.pumpAndSettle();
  }

  /// Turns the deadline on: the switch opens the picker at the earliest safe
  /// date, which is accepted.
  Future<void> pickTargetDate(WidgetTester tester) async {
    final toggle = find.byKey(const Key('profile-target-date-switch'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(DatePickerDialog)),
    );
    await tapText(tester, localizations.okButtonLabel);
  }

  Future<void> reachActivity(WidgetTester tester) async {
    await tapText(tester, goalAction);
    await tapText(tester, 'Giữ cân');
    await tapSetupAction(tester);
    await fillBody(tester);
    expect(find.text('Một ngày thường'), findsOneWidget);
  }

  // Activity now comes before the target so plans can show kcal.
  Future<void> chooseActivity(WidgetTester tester) async {
    await tapText(tester, 'Chủ yếu ngồi');
    await tapSetupAction(tester);
  }

  Future<void> openReview(WidgetTester tester) async {
    await tapText(tester, 'Chủ yếu ngồi');
    await tapSetupAction(tester);
    expect(find.byKey(const Key('profile-plan-sheet')), findsOneWidget);
  }

  Future<void> openApp(
    WidgetTester tester, {
    bool returning = false,
    bool fail = false,
    TestProfileRepository? profiles,
  }) async {
    if (!returning) reduceMotion(tester);
    final repository = TestOnboardingRepository()
      ..completed = returning
      ..failWrite = fail;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
          mealLogRepositoryProvider.overrideWithValue(TestMealLogRepository()),
          profileRepositoryProvider.overrideWithValue(
            profiles ?? TestProfileRepository(),
          ),
        ],
        child: const Application(),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final viewport in const [
    Size(320, 700),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets('profile setup and tabs fit ${viewport.width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openApp(tester);
      await tapText(tester, goalAction);
      await tapText(tester, 'Giảm cân');
      await tapSetupAction(tester);
      await fillBody(tester);
      await chooseActivity(tester);
      await tapText(tester, 'Tự chọn');
      await setCustomKg(tester, 58);
      await pickTargetDate(tester);
      await tapSetupAction(tester);
      expect(find.byKey(const Key('profile-plan-sheet')), findsOneWidget);
      await tapText(tester, 'Bắt đầu');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Application)),
      );
      final profile = container.read(savedProfileProvider).requireValue!;
      expect(profile.ageYears, 32);
      expect(profile.heightCm, 160);
      expect(profile.goal.currentWeight, 62.5);
      expect(profile.goal.targetWeight, 58);
      expect(profile.goal.targetDate, isNotNull);
      expect(profile.goal.type, GoalType.lose);
      expect(profile.activityLevel.name, 'sitting');
      // Lành's suggested budget is kept unless the user changes it.
      expect(profile.dailyEnergyKcal, isNotNull);
      expect(find.byKey(const Key('today-energy-lose')), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(AppBottomBar),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      final bar = tester.getRect(find.byKey(const Key('nav-surface')));
      final action = tester.getRect(find.byKey(const Key('nav-log-meal')));
      expect(
        bar,
        Rect.fromLTWH(20, viewport.height - 76, viewport.width - 40, 60),
      );
      expect(
        action,
        Rect.fromLTWH(viewport.width / 2 - 28, bar.top - 12, 56, 56),
      );
      final slotWidth = bar.width / 5;
      double? iconY;
      for (final (index, tab) in [
        (0, 'today'),
        (1, 'progress'),
        (3, 'achievements'),
        (4, 'menu'),
      ]) {
        final target = find.byKey(Key('nav-$tab'));
        final bounds = tester.getRect(target);
        expect(
          bounds.center.dx,
          closeTo(bar.left + (index + 0.5) * slotWidth, 0.01),
        );
        expect(bounds.width, greaterThanOrEqualTo(48));
        expect(bounds.overlaps(action), isFalse);
        final icon = find.descendant(of: target, matching: find.byType(Icon));
        final center = tester.getCenter(icon);
        expect(center.dx, closeTo(bounds.center.dx, 0.01));
        iconY ??= center.dy;
        expect(center.dy, iconY);
        expect(center.dy, bounds.center.dy);
      }
      for (final tab in ['today', 'progress', 'achievements', 'menu']) {
        await tester.tap(find.byKey(Key('nav-$tab')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('$tab-screen')), findsOneWidget);
        expect(
          tester.getCenter(find.byKey(const Key('nav-selection'))),
          tester.getCenter(find.byKey(Key('nav-$tab'))),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets(
    'bottom bar responds to fast taps and the raised action is tappable',
    (tester) async {
      await openApp(tester, returning: true);
      final tab = find.byKey(const Key('nav-progress'));
      final action = find.byKey(const Key('nav-log-meal'));
      double scaleOf(Finder target) => tester
          .widget<Transform>(
            find.descendant(of: target, matching: find.byType(Transform)).first,
          )
          .transform
          .entry(0, 0);
      await tester.tap(tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(tab), greaterThan(1));
      await tester.pumpAndSettle();
      expect(scaleOf(tab), 1);
      expect(find.byKey(const Key('progress-screen')), findsOneWidget);

      final actionBounds = tester.getRect(action);
      await tester.tapAt(Offset(actionBounds.center.dx, actionBounds.top + 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(action), greaterThan(1));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    },
  );

  testWidgets('dock selection glides and retargets during a quick tab switch', (
    tester,
  ) async {
    await openApp(tester, returning: true);
    final selection = find.byKey(const Key('nav-selection'));
    final menu = find.byKey(const Key('nav-menu'));
    final progress = find.byKey(const Key('nav-progress'));
    double selectionX() => tester.getCenter(selection).dx;
    final start = selectionX();
    final menuX = tester.getCenter(menu).dx;

    await tester.tap(menu);
    await tester.pump();
    expect(find.byKey(const Key('menu-screen')), findsOneWidget);
    expect(selectionX(), start);
    await tester.pump(const Duration(milliseconds: 90));
    final early = selectionX();
    expect((early - start) / (menuX - start), inInclusiveRange(0.1, 0.3));
    await tester.pump(const Duration(milliseconds: 130));
    final beforeRetarget = selectionX();
    expect(beforeRetarget, lessThan(menuX));
    expect(beforeRetarget, greaterThan(tester.getCenter(progress).dx));

    await tester.tap(progress);
    await tester.pump();
    expect(find.byKey(const Key('progress-screen')), findsOneWidget);
    expect(selectionX(), closeTo(beforeRetarget, 0.01));
    await tester.pump(const Duration(milliseconds: 90));
    expect(selectionX(), lessThan(beforeRetarget));
    await tester.pumpAndSettle();
    expect(selectionX(), tester.getCenter(progress).dx);
  });

  testWidgets('dock lens appears on hold and hover without activating a tab', (
    tester,
  ) async {
    await openApp(tester, returning: true);
    expect(find.bySemanticsLabel('Tiến trình'), findsOneWidget);
    final tab = find.byKey(const Key('nav-progress'));
    final lens = find.descendant(
      of: tab,
      matching: find.byKey(const Key('nav-glass-lens')),
    );
    expect(lens, findsNothing);

    final hold = await tester.startGesture(tester.getCenter(tab));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 200));
    expect(lens, findsOneWidget);
    expect(tester.getRect(lens).center, tester.getRect(tab).center);
    final selectedCapsule = find.byKey(const Key('nav-selection'));
    expect(tester.getSize(lens), tester.getSize(selectedCapsule));
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    await hold.cancel();
    await tester.pumpAndSettle();
    expect(lens, findsNothing);
    expect(find.byKey(const Key('today-screen')), findsOneWidget);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(tab));
    await tester.pumpAndSettle();
    expect(lens, findsOneWidget);
    expect(tester.getSize(lens), tester.getSize(selectedCapsule));
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(lens, findsNothing);
  });

  for (final (reducedMotion, accessibleNavigation) in [
    (false, false),
    (true, false),
    (false, true),
  ]) {
    testWidgets('Home glass bar follows scroll (reduce motion: $reducedMotion, '
        'accessible navigation: $accessibleNavigation)', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 48, bottom: 34);
      tester.view.viewPadding = tester.view.padding;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(
            disableAnimations: reducedMotion,
            accessibleNavigation: accessibleNavigation,
          );
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await openApp(tester, returning: true);
      final list = find.byType(ListView);
      final surface = find.byKey(const Key('nav-surface'));
      final action = find.byKey(const Key('nav-log-meal'));
      final navSlide = find.ancestor(
        of: surface,
        matching: find.byType(TweenAnimationBuilder<double>),
      );
      expect(
        tester.widget<TweenAnimationBuilder<double>>(navSlide).duration,
        reducedMotion ? Duration.zero : const Duration(milliseconds: 240),
      );
      final initialBounds = tester.getRect(list);
      final shown = tester.getRect(surface);
      expect(initialBounds.top, 48);
      expect(initialBounds.bottom, 600);
      expect(shown.bottom, 550);
      // Today's glass cards blur too, so layer counts are not compared;
      // the hidden nav is checked by its surface leaving the tree.

      final gesture = await tester.startGesture(initialBounds.center);
      await gesture.moveBy(const Offset(0, -60));
      await gesture.moveBy(const Offset(0, -80));
      await tester.pump();
      expect(
        action.hitTestable(),
        accessibleNavigation ? findsOneWidget : findsNothing,
      );
      if (reducedMotion) {
        expect(surface, findsNothing);
      }
      await tester.pumpAndSettle();
      expect(tester.getRect(list), initialBounds);
      expect(surface, accessibleNavigation ? findsOneWidget : findsNothing);

      // Reverse midway through the list, while the same drag is active.
      await gesture.moveBy(const Offset(0, 40));
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), shown);
      expect(action.hitTestable(), findsOneWidget);
      expect(
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
        greaterThan(0),
      );
      await gesture.up();

      // Scroll to the end: the taller first-meal card must clear the bar.
      await tester.drag(list, const Offset(0, -1200));
      await tester.pumpAndSettle();
      final logMeal = find.descendant(
        of: find.byKey(const Key('today-screen')),
        matching: find.text('Ghi bữa ăn'),
      );
      expect(logMeal.hitTestable(), findsOneWidget);
      await tester.drag(list, const Offset(0, 1400));
      await tester.pumpAndSettle();
      expect(tester.getRect(surface), shown);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dock eases into hiding and reverses from its current position', (
    tester,
  ) async {
    await openApp(tester, returning: true);
    final list = find.byType(ListView);
    final surface = find.byKey(const Key('nav-surface'));
    double top() => tester.getTopLeft(surface).dy;
    final shown = top();

    final gesture = await tester.startGesture(tester.getCenter(list));
    await gesture.moveBy(const Offset(0, -60));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(top(), shown);
    await tester.pump(const Duration(milliseconds: 90));
    final early = top();
    expect(early - shown, inInclusiveRange(4, 30));
    await tester.pump(const Duration(milliseconds: 70));
    final turningPoint = top();
    expect(turningPoint, greaterThan(early));
    expect(turningPoint, lessThan(tester.getRect(list).bottom));

    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    expect(top(), closeTo(turningPoint, 0.01));
    await tester.pump(const Duration(milliseconds: 80));
    expect(top(), lessThan(turningPoint));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(top(), shown);
  });

  testWidgets('opening another shell route restores a hidden bar', (
    tester,
  ) async {
    reduceMotion(tester);
    await openApp(tester, returning: true);
    final list = find.byType(ListView);
    final bar = find.byKey(const Key('nav-menu'));
    await tester.drag(list, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(bar.hitTestable(), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Application)),
    );
    container.read(appRouterProvider).go('/menu/about');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-screen')), findsOneWidget);
    expect(bar.hitTestable(), findsOneWidget);

    await tester.drag(list, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(bar.hitTestable(), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menu-screen')), findsOneWidget);
    expect(bar.hitTestable(), findsOneWidget);
  });

  testWidgets('bottom bar switches tabs with reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await openApp(tester, returning: true);
    final progress = find.byKey(const Key('nav-progress'));
    await tester.tap(progress);
    await tester.pump();
    expect(
      find.descendant(of: progress, matching: find.byType(AnimatedSwitcher)),
      findsNothing,
    );
    expect(
      tester
          .widget<Transform>(
            find
                .descendant(of: progress, matching: find.byType(Transform))
                .first,
          )
          .transform
          .entry(0, 0),
      1,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('progress-screen')), findsOneWidget);
  });

  for (final (goal, weight, valid, min, max) in [
    // 62.5 kg at 160 cm can lose down to 47.5 kg (BMI 18.5 = 47.36 kg).
    ('Giảm cân', '62,5', '58', 47.5, 62.0),
    // 55 kg at 160 cm can gain to 58.5 kg before BMI 22.9 (58.62 kg).
    ('Tăng cân', '55', '58', 55.5, 58.5),
  ]) {
    testWidgets(
      '$goal offers only healthy targets and preserves the draft when going back',
      (tester) async {
        await openApp(tester);
        await tapText(tester, goalAction);
        final button = find.descendant(
          of: find.byKey(setupActionKey),
          matching: find.byType(FilledButton),
        );
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tapText(tester, goal);
        await tapSetupAction(tester);
        await tapSetupAction(tester);
        // Empty fields get a short "enter it" hint.
        expect(find.text('Nhập tuổi của bạn'), findsOneWidget);
        // Male is preselected, so no sex error appears.
        expect(find.text('Chọn giới tính để tiếp tục.'), findsNothing);
        await fillBody(tester, weight: weight);
        expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
        await chooseActivity(tester);
        expect(find.byKey(const Key('profile-setup-target')), findsOneWidget);
        await tapText(tester, 'Tự chọn');
        // The slider only spans healthy targets on the goal's side.
        final slider = tester.widget<Slider>(
          find.byKey(const Key('profile-target-slider')),
        );
        expect((slider.min, slider.max), (min, max));
        await setCustomKg(tester, double.parse(valid));
        await pickTargetDate(tester);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
        await tapSetupAction(tester);
        expect(find.byKey(const Key('profile-setup-target')), findsOneWidget);
        // The custom target and its date survive going back.
        expect(
          tester
              .widget<AppRollingText>(
                find.byKey(const Key('profile-target-custom-value')),
              )
              .text,
          valid,
        );
        expect(find.byKey(const Key('profile-target-date')), findsOneWidget);
        await tapSetupAction(tester);
        expect(find.byKey(const Key('profile-plan-sheet')), findsOneWidget);
        // The plan's first tile is the chosen target.
        expect(
          find.descendant(
            of: find.byKey(const Key('profile-plan-tile-0')),
            matching: find.text('$valid kg'),
          ),
          findsOneWidget,
        );
        await tapText(tester, 'Bắt đầu');
        final mode = goal == 'Tăng cân' ? 'gain' : 'lose';
        expect(find.byKey(Key('today-energy-$mode')), findsOneWidget);
      },
    );
  }

  testWidgets('plan start saves the shown kcal and opens a guided Today', (
    tester,
  ) async {
    final profiles = TestProfileRepository();
    await openApp(tester, profiles: profiles);
    await reachActivity(tester);
    await openReview(tester);
    // Maintain, 32 y, 160 cm, 62.5 kg, mostly sitting: 1,825.6 → 1.850.
    expect(
      tester.widget<Text>(find.byKey(const Key('profile-plan-kcal'))).data,
      '1.850',
    );
    await tapText(tester, 'Bắt đầu');
    expect(profiles.profile?.dailyEnergyKcal, 1850);
    expect(profiles.profile?.goal.type, GoalType.maintain);
    // Today: "0 / 1.850 kcal", what is left, and the first-meal guide.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 1.850 kcal'), findsOneWidget);
    expect(find.text('Còn 1.850 kcal'), findsOneWidget);
    expect(find.byKey(const Key('today-first-meal')), findsOneWidget);
    expect(find.text('Ghi bữa đầu tiên hôm nay'), findsOneWidget);
    expect(
      tester.widget<AppBottomBar>(find.byType(AppBottomBar)).highlightAction,
      isTrue,
    );
  });

  testWidgets('failed profile write prevents completion and can retry', (
    tester,
  ) async {
    final profiles = TestProfileRepository()..failWrite = true;
    await openApp(tester, profiles: profiles);
    await reachActivity(tester);
    await openReview(tester);
    await tapText(tester, 'Bắt đầu');
    expect(find.byKey(const Key('onboarding-save-error')), findsOneWidget);
    expect(find.byKey(const Key('today-screen')), findsNothing);
    expect(profiles.profile, isNull);
    profiles.failWrite = false;
    await openReview(tester);
    await tapText(tester, 'Bắt đầu');
    expect(profiles.profile?.goal.type, GoalType.maintain);
    expect(profiles.profile?.goal.targetDate, isNull);
    expect(find.byKey(const Key('today-energy-maintain')), findsOneWidget);
  });

  testWidgets('failed onboarding stays on Profile Setup and can retry', (
    tester,
  ) async {
    await openApp(tester, fail: true);
    await reachActivity(tester);
    await openReview(tester);
    await tapText(tester, 'Bắt đầu');
    expect(find.byKey(const Key('onboarding-save-error')), findsOneWidget);
    expect(find.byKey(const Key('today-screen')), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Application)),
    );
    final repository = container.read(
      onboardingRepositoryProvider,
    ) as TestOnboardingRepository;
    repository.failWrite = false;
    await openReview(tester);
    await tapText(tester, 'Bắt đầu');
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });
  for (final viewport in const [
    Size(320, 700),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets('Home opens the meal picker at ${viewport.width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      if (viewport.width == 320) {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(tester, returning: true);

      final home = find.byKey(const Key('today-screen'));
      final logMeal = find.descendant(
        of: home,
        matching: find.text('Ghi bữa ăn'),
      );
      await tester.scrollUntilVisible(logMeal, 120);
      await tester.pumpAndSettle();
      await tester.tap(logMeal);
      await tester.pumpAndSettle();

      final sheet = find.byKey(const Key('meal-method-sheet'));
      expect(
        find.descendant(of: sheet, matching: find.text('Ghi bữa ăn')),
        findsOneWidget,
      );
      expect(find.text('Chụp ảnh'), findsOneWidget);
      final voice = find.text('Ghi bằng giọng nói');
      await tester.ensureVisible(voice);
      await tester.pumpAndSettle();
      expect(voice.hitTestable(), findsOneWidget);
      expect(find.text('Tìm món ăn'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(home, findsOneWidget);
      expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
    });
  }

  testWidgets('closing meal sheet preserves each origin tab', (tester) async {
    await openApp(tester, returning: true);
    for (final tab in ['today', 'progress', 'achievements', 'menu']) {
      await tester.tap(find.byKey(Key('nav-$tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-log-meal')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-meal-sheet')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('$tab-screen')), findsOneWidget);
      expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
    }
  });
  testWidgets('menu branch retains its nested route when switching tabs', (
    tester,
  ) async {
    await openApp(tester, returning: true);
    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Về Lành'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-screen')), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-today')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-screen')), findsOneWidget);
  });
  testWidgets('deep link survives the asynchronous startup check', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repository = TestOnboardingRepository()
      ..completed = true
      ..readGate = gate;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
        ],
        child: const Application(),
      ),
    );
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Application)),
    );
    container.read(appRouterProvider).go('/menu/about');
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-screen')), findsOneWidget);
  });
  testWidgets('unknown route has a usable recovery path', (tester) async {
    await openApp(tester, returning: true);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Application)),
    );
    container.read(appRouterProvider).go('/missing-page');
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy trang'), findsOneWidget);
    await tester.tap(find.text('Về Hôm nay'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });
  testWidgets('startup read error exposes a usable retry', (tester) async {
    reduceMotion(tester);
    final repository = TestOnboardingRepository()..failRead = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
        ],
        child: const Application(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thử lại'), findsOneWidget);
    repository.failRead = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text(goalAction), findsOneWidget);
  });
  testWidgets('English localization uses the same navigation flow', (
    tester,
  ) async {
    final repository = TestOnboardingRepository()..completed = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
        ],
        child: const Application(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-log-meal')));
    await tester.pumpAndSettle();
    expect(find.text('Log a meal'), findsOneWidget);
    expect(find.text('Choose how to start'), findsOneWidget);
    expect(find.text('Log by voice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('large text on a small phone keeps profile setup usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openApp(tester);
    await reachActivity(tester);
    await openReview(tester);
    await tapText(tester, 'Bắt đầu');
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
