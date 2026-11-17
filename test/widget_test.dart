import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  testWidgets(
    'welcome starts with the decoded background and reuses it in setup',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.runAsync(AppBackground.preload);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingRepositoryProvider.overrideWithValue(
              TestOnboardingRepository(),
            ),
          ],
          child: const Application(),
        ),
      );
      final background = find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is ExactAssetImage,
        ),
        matching: find.byType(RawImage),
      );
      final initialImage = tester.widget<RawImage>(background).image;
      expect(initialImage, isNotNull);
      await tester.pumpAndSettle();

      expect(find.text('Lành'), findsOneWidget);
      final setup = find.text('Đặt mục tiêu của tôi');
      expect(setup, findsOneWidget);
      await tester.ensureVisible(setup);
      await tester.tap(setup);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile-setup-goal')), findsOneWidget);
      expect(
        tester.widget<RawImage>(background).image!.isCloneOf(initialImage!),
        isTrue,
      );
    },
  );
}
