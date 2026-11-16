import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/app/lanh_app.dart';
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
        child: const LanhApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

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
        child: const LanhApp(),
      ),
    );
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanhApp)),
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
      tester.element(find.byType(LanhApp)),
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
        child: const LanhApp(),
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
        child: const LanhApp(locale: Locale('en')),
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
