import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/main.dart' as app;
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native SQLite retains profile across a new app scope', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    app.main();
    await tester.pumpAndSettle();
    final start = find.text('Đặt mục tiêu của tôi');
    if (start.evaluate().isNotEmpty) {
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      final action = find.byKey(const Key('profile-setup-action'));
      await tap(start);
      await tap(find.text('Giữ cân'));
      await tap(action);
      for (final (field, value) in [
        ('age', '32'),
        ('height', '160'),
        ('current-weight', '62'),
      ]) {
        final input = find.descendant(
          of: find.byKey(Key('profile-$field')),
          matching: find.byType(EditableText),
        );
        await tester.ensureVisible(input);
        await tester.enterText(input, value);
        await tester.pumpAndSettle();
      }
      tester
          .widget<TextButton>(find.byKey(const Key('profile-sex-female')))
          .onPressed!
          .call();
      await tester.pumpAndSettle();
      await tap(action);
      await tap(find.text('Chủ yếu ngồi'));
      await tap(action);
      await tap(find.text('Về Hôm nay'));
      for (
        var attempt = 0;
        attempt < 30 &&
            find.byKey(const Key('today-screen')).evaluate().isEmpty;
        attempt++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(key: UniqueKey(), child: const Application()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    expect(find.byKey(const Key('today-energy-maintain')), findsOneWidget);
    final profile = ProviderScope.containerOf(
      tester.element(find.byType(Application)),
    ).read(savedProfileProvider).requireValue!;
    expect(profile.ageYears, 32);
    expect(profile.heightCm, 160);
    expect(profile.goal.currentWeight, 62);
    await tester.tap(find.byKey(const Key('nav-log-meal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-meal-sheet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });
}
