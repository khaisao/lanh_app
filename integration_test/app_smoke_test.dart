import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/main.dart' as app;
import 'package:material_ui/material_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native preferences retain introduction across a new app scope', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    final start = find.text('Ghi bữa ăn đầu tiên');
    if (start.evaluate().isNotEmpty) {
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('close-meal-sheet')));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(key: UniqueKey(), child: const Application()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-log-meal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-meal-sheet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-screen')), findsOneWidget);
  });
}
