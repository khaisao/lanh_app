import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the exported squircle keeps the card interior continuous', () {
    const rect = Rect.fromLTWH(0, 0, 342, 82);
    const border = AppSquircleBorder(
      radius: AppRadii.exportCardSquircle,
      side: BorderSide(width: AppBorders.selected),
    );
    final outline = border.getOuterPath(rect);
    for (final point in const [
      Offset(171, 41),
      Offset(1, 41),
      Offset(341, 41),
      Offset(171, 1),
      Offset(171, 81),
    ]) {
      expect(outline.contains(point), isTrue);
    }
    expect(outline.contains(const Offset(1, 1)), isFalse);
    expect(border.getInnerPath(rect).contains(const Offset(171, 1)), isFalse);
  });
}
