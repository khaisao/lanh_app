import 'package:app_ui/app_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget button) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: button)),
);

void main() {
  testWidgets('label-only button shows text without icons', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppButton(onPressed: () => taps++, label: 'Tiếp tục')),
    );
    expect(find.text('Tiếp tục'), findsOneWidget);
    expect(find.byType(AppIcon), findsNothing);
    await tester.tap(find.byType(AppButton));
    expect(taps, 1);
  });

  testWidgets('icons sit on the requested side of the label', (tester) async {
    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              key: const Key('leading'),
              onPressed: () {},
              label: 'Xác nhận',
              leadingIcon: 'ph-check-bold',
            ),
            AppButton(
              key: const Key('trailing'),
              onPressed: () {},
              label: 'Ước lượng bữa ăn',
              trailingIcon: 'ph-arrow-right-bold',
            ),
          ],
        ),
      ),
    );
    Finder iconIn(String key) => find.descendant(
      of: find.byKey(Key(key)),
      matching: find.byType(AppIcon),
    );
    expect(
      tester.getCenter(iconIn('leading')).dx,
      lessThan(tester.getCenter(find.text('Xác nhận')).dx),
    );
    expect(
      tester.getCenter(iconIn('trailing')).dx,
      greaterThan(tester.getCenter(find.text('Ước lượng bữa ăn')).dx),
    );
    expect(
      tester.getSize(iconIn('leading')),
      const Size.square(AppSizes.buttonIcon),
    );
  });

  testWidgets('icon follows the enabled and disabled foreground', (
    tester,
  ) async {
    ColorFilter? iconColor() =>
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter;

    await tester.pumpWidget(
      _host(
        AppButton(onPressed: () {}, label: 'Gửi', leadingIcon: 'ph-plus-bold'),
      ),
    );
    final enabled = iconColor();
    await tester.pumpWidget(
      _host(
        const AppButton(
          onPressed: null,
          label: 'Gửi',
          leadingIcon: 'ph-plus-bold',
        ),
      ),
    );
    expect(iconColor(), isNot(enabled));
  });

  testWidgets('loading replaces the leading icon with a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AppButton(
          onPressed: () {},
          label: 'Đang lưu',
          leadingIcon: 'ph-check-bold',
          loading: true,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AppIcon), findsNothing);
  });

  testWidgets('fullWidth stretches even inside a centred column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                key: const Key('wide'),
                onPressed: () {},
                fullWidth: true,
                label: 'Bắt đầu',
                trailingIcon: 'ph-arrow-right-bold',
              ),
              AppButton(
                key: const Key('hug'),
                onPressed: () {},
                label: 'Bắt đầu',
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const Key('wide'))), const Size(342, 56));
    expect(tester.getSize(find.byKey(const Key('hug'))).width, lessThan(200));
  });

  testWidgets('primary has the Sleek shadow; card variant does not', (
    tester,
  ) async {
    List<BoxShadow>? shadowOf(String key) {
      final boxes = find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(DecoratedBox),
      );
      for (final box in tester.widgetList<DecoratedBox>(boxes)) {
        final decoration = box.decoration;
        if (decoration is ShapeDecoration && decoration.shadows != null) {
          return decoration.shadows;
        }
      }
      return null;
    }

    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              key: const Key('primary'),
              onPressed: () {},
              label: 'Tiếp tục',
            ),
            AppButton.card(
              key: const Key('card'),
              onPressed: () {},
              label: 'Ghi bữa ăn',
              leadingIcon: 'ph-plus-bold',
            ),
          ],
        ),
      ),
    );
    expect(shadowOf('primary'), AppShadows.primaryAction);
    expect(shadowOf('card'), isNull);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byKey(const Key('card')),
          matching: find.byType(AppIcon),
        ),
      ),
      const Size.square(AppSizes.buttonIconCard),
    );
  });
}
