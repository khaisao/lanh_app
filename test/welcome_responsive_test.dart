import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  testWidgets('welcome stays usable across common phone viewports', (
    tester,
  ) async {
    final repository = TestOnboardingRepository();
    final viewports = <Size>[
      const Size(320, 700),
      const Size(360, 800),
      const Size(390, 844),
      const Size(430, 932),
    ];

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final viewport in viewports) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingRepositoryProvider.overrideWithValue(repository),
          ],
          child: const Application(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ghi bữa ăn đầu tiên'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
