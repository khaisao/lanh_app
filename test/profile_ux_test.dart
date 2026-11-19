import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_profile_repository.dart';

void main() {
  testWidgets('body shows a live BMI insight after the required values', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester);

    expect(find.byKey(const Key('profile-body-insight')), findsOneWidget);
    expect(find.text('BMI hiện tại'), findsOneWidget);
    expect(find.text('Trong vùng khỏe mạnh'), findsOneWidget);
    expect(find.textContaining('BMI chỉ là chỉ số tham khảo'), findsOneWidget);
  });

  testWidgets('adult target screen offers a tap-to-fill suggestion', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester);
    await tester.tap(find.byKey(const Key('profile-setup-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-target-suggestions')), findsOneWidget);
    expect(find.text('Gợi ý từ Lành'), findsOneWidget);
    final suggestion = find.byKey(const Key('profile-target-suggestion-five'));
    expect(suggestion, findsOneWidget);
    await tester.tap(suggestion);
    await tester.pumpAndSettle();

    final target = tester.widget<TextField>(
      find.byKey(const Key('profile-target-weight')),
    );
    expect(target.controller?.text, '59.4');
    expect(find.textContaining('Khoảng'), findsWidgets);
    expect(find.textContaining('kg/tuần'), findsWidgets);
  });
}

Future<void> _pump(WidgetTester tester) async {
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
}

Future<void> _chooseGoal(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('profile-setup-action')));
  await tester.pumpAndSettle();
}

Future<void> _fillBody(WidgetTester tester) async {
  await _enter(tester, 'profile-age', '32');
  await _enter(tester, 'profile-height', '160');
  await _enter(tester, 'profile-current-weight', '62,5');
  tester
      .widget<TextButton>(find.byKey(const Key('profile-sex-female')))
      .onPressed!
      .call();
  await tester.pumpAndSettle();
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
