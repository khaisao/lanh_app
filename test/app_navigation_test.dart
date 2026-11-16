import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  Future<void> openApp(
    WidgetTester tester, {
    bool returning = false,
    bool fail = false,
  }) async {
    final repository = TestOnboardingRepository()
      ..completed = returning
      ..failWrite = fail;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
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
    testWidgets('goal and tabs fit ${viewport.width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openApp(tester);
      final goalButton = find.text('Đặt mục tiêu của tôi');
      await tester.ensureVisible(goalButton);
      await tester.tap(goalButton);
      await tester.pumpAndSettle();
      expect(find.text('Bạn muốn hướng đến điều gì?'), findsOneWidget);
      final choice = find.text('Giảm cân');
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('goal-primary-action')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      for (
        var i = 0;
        i < 2 && find.byKey(const Key('goal-screen')).evaluate().isNotEmpty;
        i++
      ) {
        final back = find.text('Quay lại');
        await tester.ensureVisible(back);
        await tester.tap(back);
        await tester.pumpAndSettle();
      }
      final mealButton = find.text('Ghi bữa ăn đầu tiên');
      await tester.ensureVisible(mealButton);
      await tester.tap(mealButton);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-meal-sheet')));
      await tester.pumpAndSettle();
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

  testWidgets('first meal opens the picker over Today after onboarding', (
    tester,
  ) async {
    await openApp(tester);
    expect(find.text('Ghi bữa ăn đầu tiên'), findsOneWidget);
    await tester.ensureVisible(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pump();
    await tester.tap(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-meal-sheet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    expect(find.text('Ghi bữa ăn đầu tiên'), findsNothing);
  });
  testWidgets('failed storage stays on welcome and exposes retry', (
    tester,
  ) async {
    await openApp(tester, fail: true);
    await tester.ensureVisible(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pump();
    await tester.tap(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pumpAndSettle();
    expect(find.text('Ghi bữa ăn đầu tiên'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-save-error')), findsOneWidget);
    expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
    expect(find.byKey(const Key('today-screen')), findsNothing);
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
    expect(find.text('Ghi bữa ăn đầu tiên'), findsOneWidget);
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
  testWidgets('large text on a small phone keeps welcome and sheet usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await openApp(tester);
    await tester.ensureVisible(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pump();
    await tester.tap(find.text('Ghi bữa ăn đầu tiên'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
