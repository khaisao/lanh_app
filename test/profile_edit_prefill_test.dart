import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/profile_setup/domain/profile.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_profile_repository.dart';

void main() {
  testWidgets('editing from Menu starts from the saved profile', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final now = DateTime(2026, 11, 1);
    final profiles = TestProfileRepository()
      ..profile = Profile(
        ageYears: 28,
        heightCm: 158,
        sex: ProfileSex.female,
        activityLevel: ActivityLevel.light,
        goal: Goal(
          type: GoalType.maintain,
          currentWeight: 52.5,
          createdAt: now,
          updatedAt: now,
        ),
        dailyEnergyKcal: 1850,
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(profiles)],
        child: MaterialApp(
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
    );
    await tester.pumpAndSettle();

    // The saved goal is already chosen, so Continue goes straight on.
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();
    final texts = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.controller!.text)
        .toList();
    expect(texts, containsAll(['28', '158', '52,5']));
  });
}
