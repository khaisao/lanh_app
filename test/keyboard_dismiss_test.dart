import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<FocusNode> pump(WidgetTester tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppKeyboardDismiss(child: child!),
        home: Scaffold(
          body: Column(
            children: [
              TextField(key: const Key('field'), focusNode: focus),
              const Expanded(child: SizedBox(key: Key('outside'))),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    return focus;
  }

  testWidgets('a tap outside the field closes the keyboard', (tester) async {
    final focus = await pump(tester);
    await tester.tap(find.byKey(const Key('outside')));
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('a drag outside the field keeps it focused', (tester) async {
    final focus = await pump(tester);
    await tester.drag(find.byKey(const Key('outside')), const Offset(0, -80));
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });
}
