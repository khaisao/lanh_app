import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('back and close expose labels and the complete 56 dp target', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var backs = 0;
    var closes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AppNavigationButton.back(
                tooltip: 'Back',
                onPressed: () => backs++,
              ),
              AppNavigationButton.close(
                tooltip: 'Close',
                onPressed: () => closes++,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    for (final button in find.byType(AppNavigationButton).evaluate()) {
      final finder = find.byWidget(button.widget);
      expect(tester.getSize(finder), const Size.square(56));
      // The padding around the 44 dp circle must also accept taps.
      await tester.tapAt(tester.getTopLeft(finder) + const Offset(2, 28));
      await tester.pumpAndSettle();
    }
    expect(backs, 1);
    expect(closes, 1);
    semantics.dispose();
  });

  testWidgets('reduced motion keeps a pressed navigation circle steady', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: AppNavigationButton.back(tooltip: 'Back', onPressed: () {}),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppNavigationButton)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
