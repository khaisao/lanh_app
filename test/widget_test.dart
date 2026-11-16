import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  testWidgets('app starts on the welcome screen', (tester) async {
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
    await tester.pumpAndSettle();

    expect(find.text('Lành'), findsOneWidget);
    expect(find.text('Ghi bữa ăn đầu tiên'), findsOneWidget);
  });
}
