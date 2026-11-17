import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  Widget app() => ProviderScope(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(
        TestOnboardingRepository(),
      ),
    ],
    child: const Application(),
  );

  final mascot = find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image ==
            const AssetImage('assets/design/images/welcome-broccoli.png'),
  );

  testWidgets('welcome keeps its single goal action on phone viewports', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    await tester.runAsync(() async {
      await (FontLoader(
        AppFonts.heading,
      )..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'))).load();
      await (FontLoader(AppFonts.body)
            ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))
            ..addFont(
              rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf'),
            ))
          .load();
    });
    for (final viewport in const [
      Size(320, 700),
      Size(360, 800),
      Size(390, 844),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = viewport;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(tester.getSize(mascot), const Size(224, 224));
      final action = find.byType(AppButton);
      expect(action, findsOneWidget);
      expect(
        tester.getRect(action),
        Rect.fromLTWH(24, viewport.height - 128, viewport.width - 48, 56),
      );
      if (viewport.width == 390) {
        expect(tester.getTopLeft(mascot).dy, closeTo(198.25, 0.5));
      }
      await tester.ensureVisible(action);
      await tester.pump();
      expect(action.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('welcome motion responds to presses and Reduce Motion', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final before = tester.getTopLeft(mascot);
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.getTopLeft(mascot), isNot(before));
    final action = find.byType(AppButton);
    await tester.ensureVisible(action);
    await tester.pump();
    final press = await tester.startGesture(tester.getCenter(action));
    await tester.pump();
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.97,
    );
    await press.cancel();

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pumpAndSettle();
    final still = tester.getTopLeft(mascot);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getTopLeft(mascot), still);
  });
}
