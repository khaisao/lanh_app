import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/test_profile_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android shows age-aware teen guidance', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
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
    tester
        .widget<TextButton>(find.byKey(const Key('profile-sex-female')))
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();

    expect(find.text('Mục tiêu an toàn trong giai đoạn lớn'), findsOneWidget);
    expect(find.byKey(const Key('profile-target-weight')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android shows BMI insight and target suggestions', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
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
    await _enter(tester, 'profile-age', '32');
    await _enter(tester, 'profile-height', '160');
    await _enter(tester, 'profile-current-weight', '62,5');
    tester
        .widget<TextButton>(find.byKey(const Key('profile-sex-female')))
        .onPressed!
        .call();
    await tester.pumpAndSettle();
    expect(find.text('BMI hiện tại'), findsOneWidget);
    expect(find.text('Trong vùng khỏe mạnh'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();
    expect(find.text('Gợi ý từ Lành'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-target-suggestion-five')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('profile-target-weight')))
          .controller
          ?.text,
      '59.4',
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}
