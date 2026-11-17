import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:material_ui/material_ui.dart'
    show DatePickerDialog, FilledButton, MaterialLocalizations;

import 'support/test_goal_repository.dart';
import 'support/test_onboarding_repository.dart';

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

  Future<void> fillBody(WidgetTester tester) async {
    await enterProfileValue(tester, 'age', '32');
    await enterProfileValue(tester, 'height', '160');
    await enterProfileValue(tester, 'current-weight', '62,5');
    await tapText(tester, 'Nữ');
    await tapSetupAction(tester);
  }

  Future<void> pickTargetDate(WidgetTester tester) async {
    final date = find.byKey(const Key('profile-target-date'));
    await tester.ensureVisible(date);
    await tester.tap(date);
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

  Future<void> openReview(WidgetTester tester) async {
    await tapText(tester, 'Chủ yếu ngồi');
    await tapSetupAction(tester);
    expect(find.text('Xem lại thông tin'), findsOneWidget);
  }

  Future<void> openApp(
    WidgetTester tester, {
    bool returning = false,
    bool fail = false,
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
      await enterProfileValue(tester, 'target-weight', '58');
      await pickTargetDate(tester);
      await tapSetupAction(tester);
      await openReview(tester);
      await tapText(tester, 'Về Hôm nay');
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Application)),
      );
      expect(container.read(goalControllerProvider).value, isNull);
      expect(tester.takeException(), isNull);
      final bar = tester.getRect(find.byKey(const Key('nav-surface')));
      final action = tester.getRect(find.byKey(const Key('nav-log-meal')));
      final today = tester.getRect(find.byKey(const Key('nav-today')));
      final menu = tester.getRect(find.byKey(const Key('nav-menu')));
      expect(
        bar,
        Rect.fromLTWH(16, viewport.height - 80, viewport.width - 32, 64),
      );
      expect(
        action,
        Rect.fromLTWH(viewport.width / 2 - 32, bar.top - 16, 64, 64),
      );
      expect(today.left - bar.left, 9);
      expect(bar.right - menu.right, 9);
      expect(today.width, closeTo(menu.width, 0.01));
      if (viewport.width == 320) expect(today.width, 51.5);
      for (final tab in ['today', 'progress', 'achievements', 'menu']) {
        await tester.tap(find.byKey(Key('nav-$tab')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('$tab-screen')), findsOneWidget);
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
            find.ancestor(of: target, matching: find.byType(Transform)).first,
          )
          .transform
          .entry(0, 0);
      await tester.tap(tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(tab), lessThan(1));
      await tester.pumpAndSettle();
      expect(scaleOf(tab), 1);
      expect(find.byKey(const Key('progress-screen')), findsOneWidget);

      final actionBounds = tester.getRect(action);
      await tester.tapAt(Offset(actionBounds.center.dx, actionBounds.top + 8));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(scaleOf(action), lessThan(1));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    },
  );

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
            find.ancestor(of: progress, matching: find.byType(Transform)).first,
          )
          .transform
          .entry(0, 0),
      1,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('progress-screen')), findsOneWidget);
  });

  for (final (goal, invalid, valid, error) in [
    ('Giảm cân', '64', '58', 'Cân nặng mong muốn phải thấp hơn cân hiện tại.'),
    ('Tăng cân', '58', '65', 'Cân nặng mong muốn phải cao hơn cân hiện tại.'),
  ]) {
    testWidgets(
      '$goal validates the target and preserves the draft when going back',
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
        expect(find.text('Nhập tuổi bằng số nguyên dương.'), findsOneWidget);
        await fillBody(tester);
        expect(find.byKey(const Key('profile-setup-target')), findsOneWidget);
        await enterProfileValue(tester, 'target-weight', invalid);
        await tapSetupAction(tester);
        expect(find.text(error), findsOneWidget);
        expect(find.text('Chọn ngày sau hôm nay.'), findsOneWidget);
        await enterProfileValue(tester, 'target-weight', valid);

        await pickTargetDate(tester);
        await tapSetupAction(tester);
        expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
        expect(tester.widget<FilledButton>(button).onPressed, isNull);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('profile-setup-target')), findsOneWidget);
        expect(find.text(valid), findsOneWidget);
        await tapSetupAction(tester);
        await openReview(tester);
        expect(find.text('Cân nặng mong muốn · $valid kg'), findsOneWidget);
      },
    );
  }

  testWidgets('failed onboarding stays on Profile Setup and can retry', (
    tester,
  ) async {
    await openApp(tester, fail: true);
    await reachActivity(tester);
    await openReview(tester);
    await tapText(tester, 'Về Hôm nay');
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
    await tapText(tester, 'Về Hôm nay');
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });
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
        overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
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
        overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
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
        overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
        child: const Application(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your day'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-log-meal')));
    await tester.pumpAndSettle();
    expect(find.text('How would you like to log your meal?'), findsOneWidget);
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
    await tapText(tester, 'Về Hôm nay');
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
