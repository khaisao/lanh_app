import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';

import '../test/support/test_goal_repository.dart';
import '../test/support/test_onboarding_repository.dart';
import '../test/support/test_profile_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Glass bar follows native scroll throughout the app shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            TestOnboardingRepository()..completed = true,
          ),
          goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
        ],
        child: const Application(),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    final bar = find.byKey(const Key('nav-surface'));
    final action = find.byKey(const Key('nav-log-meal'));
    for (final screen in [
      'today',
      'progress',
      'achievements',
      'menu',
      'about',
    ]) {
      if (screen == 'about') {
        await tester.tap(find.text('Về Lành'));
      } else {
        await tester.tap(find.byKey(Key('nav-$screen')));
      }
      await tester.pumpAndSettle();
      expect(find.byKey(Key('$screen-screen')), findsOneWidget);
      final viewport = tester.getRect(list);
      final shown = tester.getRect(bar);
      expect(
        viewport.bottom,
        tester.view.physicalSize.height / tester.view.devicePixelRatio,
      );
      expect(shown.bottom, lessThan(viewport.bottom));

      await tester.drag(list, const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(action.hitTestable(), findsNothing, reason: screen);
      expect(tester.getRect(list), viewport);

      await tester.drag(list, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(tester.getRect(bar), shown);
      expect(action.hitTestable(), findsOneWidget, reason: screen);
    }
    final menu = find.byKey(const Key('nav-menu'));
    final selection = find.byKey(const Key('nav-selection'));
    final lens = find.byKey(const Key('nav-glass-lens'));
    for (final (button, expectedBounds) in [
      (menu, tester.getRect(selection)),
      (action, tester.getRect(action).deflate(3)),
    ]) {
      final hold = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      final bounds = tester.getRect(lens);
      expect(bounds.size, expectedBounds.size);
      expect((bounds.center - expectedBounds.center).distance, lessThan(0.01));
      await hold.cancel();
      await tester.pumpAndSettle();
      expect(lens, findsNothing);
      expect(find.byKey(const Key('about-screen')), findsOneWidget);
    }
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-meal-sheet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('about-screen')), findsOneWidget);
  });
}
