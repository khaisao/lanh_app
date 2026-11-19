import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/profile_setup/data/sqlite_profile_repository.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('teen setup uses age-based guidance without a numeric target', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            SqliteProfileRepository(),
          ),
        ],
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

    await tester.tap(find.text('Giảm cân'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();
    await _enter(tester, 'profile-age', '13');
    await _enter(tester, 'profile-height', '160');
    await _enter(tester, 'profile-current-weight', '42');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final female = find.byKey(const Key('profile-sex-female'));
    await tester.ensureVisible(female);
    tester.widget<TextButton>(female).onPressed!.call();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();

    expect(find.text('Mục tiêu an toàn trong giai đoạn lớn'), findsOneWidget);
    expect(find.byKey(const Key('profile-target-weight')), findsNothing);
    expect(find.textContaining('vùng tham chiếu theo tuổi'), findsNWidgets(2));
  });

  testWidgets('teen maintain goal also shows growth guidance', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            SqliteProfileRepository(),
          ),
        ],
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
    tester
        .widget<AppSelectionTile>(
          find.byKey(const Key('profile-goal-maintain')),
        )
        .onPressed
        .call();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();
    await _enter(tester, 'profile-age', '13');
    await _enter(tester, 'profile-height', '160');
    await _enter(tester, 'profile-current-weight', '42');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    tester
        .widget<TextButton>(find.byKey(const Key('profile-sex-female')))
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();

    expect(find.text('Mục tiêu an toàn trong giai đoạn lớn'), findsOneWidget);
    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
  });
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}
