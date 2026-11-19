import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_setup_screen.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_profile_repository.dart';

void main() {
  testWidgets('BMI card appears only once every value is in', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    final card = find.byKey(const Key('profile-body-insight'));
    expect(card, findsNothing);
    await _enter(tester, 'profile-age', '32');
    await _enter(tester, 'profile-height', '160');
    // Weight still missing: no partial reading.
    expect(card, findsNothing);
    await _enter(tester, 'profile-current-weight', '62,5');
    // Male is preselected, so the reading appears once the numbers are in.
    expect(card, findsOneWidget);
    await _fillBody(tester, weight: '62,5');
    expect(card, findsOneWidget);
    // An implausible value closes it again.
    await _enter(tester, 'profile-height', '16');
    expect(card, findsNothing);
  });

  testWidgets('body reads BMI with the WHO Asian adult cut-offs', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, weight: '62,5');

    // 62.5 kg / 1.60² = 24.4: overweight on the Asian scale (23–24.9).
    expect(find.text('BMI ước tính'), findsOneWidget);
    expect(find.text('24,4'), findsOneWidget);
    expect(find.text('Cao hơn vùng khỏe mạnh'), findsOneWidget);
    expect(
      find.text('Theo ngưỡng WHO cho người châu Á: bình thường 18,5–22,9.'),
      findsOneWidget,
    );
    expect(find.text('Lành đọc theo người lớn.'), findsOneWidget);
  });

  testWidgets('body rejects implausible height and weight', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, height: '16', weight: '6,2');
    await _continue(tester);

    expect(find.text('Chiều cao trong khoảng 100–250 cm'), findsOneWidget);
    expect(find.text('Cân nặng trong khoảng 25–350 kg'), findsOneWidget);
    expect(find.byKey(const Key('profile-setup-body')), findsOneWidget);
  });

  testWidgets('target offers three Lành plans and switches into custom', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, weight: '62,5');
    await _continue(tester);
    await _sitting(tester);

    expect(find.text('Giảm cân · hiện tại 62,5 kg'), findsOneWidget);
    expect(find.text('NHẸ NHÀNG · 5%'), findsOneWidget);
    expect(find.text('VỪA PHẢI · 7%'), findsOneWidget);
    expect(find.text('MỐC DÀI HƠN · 10%'), findsOneWidget);
    expect(find.text('59'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
    // The "Đang chọn · Chỉnh" row between plans is gone.
    expect(find.textContaining('Đang chọn'), findsNothing);
    // 10% of 62.5 kg over 26 weeks ≈ 0.24 kg/week.
    expect(find.text('~0,24 kg/tuần'), findsNWidgets(3));
    // 1,825.6 kcal used − 0.24 × 1,100 ≈ 1,561 kcal.
    expect(find.text('≈ 1.550 kcal/ngày'), findsNWidgets(3));

    // Custom mode starts from the selected plan.
    await tester.ensureVisible(find.text('Tự chọn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tự chọn'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-target-kg-picker')), findsOneWidget);
    expect(find.text('59 kg'), findsOneWidget);
    expect(find.text('Nhịp nhẹ nhàng, dễ duy trì'), findsOneWidget);

    final chip = find.byKey(const Key('profile-target-kg-50'));
    await tester.scrollUntilVisible(
      chip,
      -100,
      scrollable: find.descendant(
        of: find.byKey(const Key('profile-target-kg-picker')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text('50 kg'), findsOneWidget);
    expect(find.text('Giảm 12,5 kg so với 62,5 kg hiện tại'), findsOneWidget);
  });

  testWidgets('target explains when no healthy loss target exists', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    // 47 kg / 1.60² = 18.4, already under WHO 18.5.
    await _fillBody(tester, weight: '47');
    await _continue(tester);
    await _sitting(tester);

    expect(find.byKey(const Key('profile-target-unavailable')), findsOneWidget);
    expect(find.byKey(const Key('profile-target-mode')), findsNothing);
    final button = find.descendant(
      of: find.byKey(const Key('profile-setup-action')),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
  });

  testWidgets('activity estimates daily energy before the target', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, weight: '62,5');
    await _continue(tester);

    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
    expect(
      find.text('Chọn một mức để xem năng lượng ước tính.'),
      findsOneWidget,
    );
    final tile = find.byKey(const Key('profile-activity-sitting'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    // Mifflin-St Jeor 1,304 × PAL 1.40 = 1,825.6 kcal.
    expect(find.text('1.850 kcal/ngày'), findsOneWidget);

    final variable = find.byKey(const Key('profile-activity-variable'));
    await tester.ensureVisible(variable);
    await tester.pumpAndSettle();
    await tester.tap(variable);
    await tester.pumpAndSettle();
    // Unknown schedules show the PAL 1.40–1.75 range.
    expect(find.text('1.850–2.300 kcal/ngày'), findsOneWidget);
  });

  testWidgets('target refuses a loss that needs eating below the floor', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    // 80 years, 145 cm, 48 kg, mostly sitting: about 1,155 kcal used, under
    // the 1,200 kcal floor, although BMI 22.8 would allow a lower weight.
    await _fillBody(tester, age: '80', height: '145', weight: '48');
    await _continue(tester);
    await _sitting(tester);

    expect(find.byKey(const Key('profile-target-unavailable')), findsOneWidget);
    expect(find.textContaining('1.200 kcal/ngày'), findsOneWidget);
    final button = find.descendant(
      of: find.byKey(const Key('profile-setup-action')),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
  });

  testWidgets('pregnancy: plan sheet tracks without a kcal number', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, weight: '62,5');
    final toggle = find.byKey(const Key('profile-pregnancy'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đang mang thai hoặc cho con bú'));
    await tester.pumpAndSettle();
    await _continue(tester);

    expect(find.byKey(const Key('profile-pregnancy-note')), findsOneWidget);
    expect(find.byKey(const Key('profile-energy-estimate')), findsNothing);
    // Activity is the last step: confirm opens the plan, no target step.
    await _sitting(tester);
    expect(find.byKey(const Key('profile-plan-sheet')), findsOneWidget);
    expect(find.byKey(const Key('profile-plan-no-kcal')), findsOneWidget);
    expect(
      find.text('Nhu cầu thay đổi theo từng giai đoạn. Hỏi bác sĩ khi cần.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile-plan-budget')), findsNothing);
    _expectTile(0, 'Giảm cân');
    _expectTile(1, '62,5 kg');
    _expectTile(2, 'Chủ yếu ngồi');
  });

  testWidgets('teen (19): plan sheet without kcal; adult (20) gets kcal', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, age: '19', weight: '62,5');
    await _continue(tester);
    await _sitting(tester);
    expect(find.byKey(const Key('profile-plan-no-kcal')), findsOneWidget);
    expect(
      find.text('Giai đoạn này cần đủ năng lượng. Hỏi chuyên gia khi cần.'),
      findsOneWidget,
    );

    // "Chỉnh lại" closes the sheet and keeps every answer.
    final edit = find.byKey(const Key('profile-plan-edit'));
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-plan-sheet')), findsNothing);
    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);

    await _back(tester);
    await _enter(tester, 'profile-age', '20');
    await _continue(tester);
    await _continue(tester);
    // Now an adult: the target step appears before the plan.
    expect(find.byKey(const Key('profile-setup-target')), findsOneWidget);
  });

  testWidgets('maintain: budget equals the body\'s use', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giữ cân');
    await _fillBody(tester, weight: '62,5');
    await _continue(tester);
    await _sitting(tester);

    // Mifflin-St Jeor 1,304 × PAL 1.40 = 1,825.6 → 1.850.
    expect(find.text('1.850'), findsOneWidget);
    expect(find.text('Bằng mức cơ thể dùng'), findsOneWidget);
    _expectTile(0, '62,5 kg');
    _expectTile(1, 'Chủ yếu ngồi');
    // 62.5 / 1.60² = 24.4.
    _expectTile(2, '24,4');
  });

  testWidgets('lose: eat + cut add up to the body\'s use', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    await _fillBody(tester, weight: '62,5');
    await _continue(tester);
    await _sitting(tester);
    await _continue(tester);

    // Gentle 0.24 kg/week: 1,825.6 − 264 = 1,561 → 1.550; body ~1.850.
    expect(find.text('1.550'), findsOneWidget);
    expect(find.text('Nạp 1.550'), findsOneWidget);
    expect(find.text('Bớt 300'), findsOneWidget);
    expect(find.text('Cơ thể dùng ~1.850'), findsOneWidget);
    _expectTile(0, '59 kg');
    _expectTile(1, '0,24 kg');
  });

  testWidgets('gain: body\'s use plus a capped surplus', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Tăng cân');
    // Male (preselected), 25 years, 175 cm, 58 kg, some walking.
    await _fillBody(
      tester,
      age: '25',
      height: '175',
      weight: '58',
      female: false,
    );
    await _continue(tester);
    final light = find.byKey(const Key('profile-activity-light'));
    await tester.ensureVisible(light);
    await tester.pumpAndSettle();
    await tester.tap(light);
    await tester.pumpAndSettle();
    await _continue(tester);
    await _continue(tester);

    // BMR 1,553.75 × 1.55 = 2,408 → 2.400; +0.145 kg/week ≈ +160 → 2.550.
    expect(find.text('2.550'), findsOneWidget);
    expect(find.text('Cơ thể dùng 2.400'), findsOneWidget);
    expect(find.text('Thêm 150'), findsOneWidget);
    _expectTile(0, '61 kg');
    _expectTile(1, '0,15 kg');
  });

  testWidgets('no healthy loss target offers Maintain and finishes there', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    // 47 kg / 1.60² = 18.4: already under 18.5.
    await _fillBody(tester, weight: '47');
    await _continue(tester);
    await _sitting(tester);
    await _continue(tester);
    final switchButton = find.byKey(
      const Key('profile-target-switch-maintain'),
    );
    await tester.ensureVisible(switchButton);
    await tester.pumpAndSettle();
    await tester.tap(switchButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-setup-activity')), findsOneWidget);
    await _continue(tester);
    expect(find.text('Bằng mức cơ thể dùng'), findsOneWidget);
  });

  testWidgets('number fields reject malformed input', (tester) async {
    await _pump(tester);
    await _chooseGoal(tester, 'Giảm cân');
    String text(String key) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
    await _enter(tester, 'profile-current-weight', '61,5');
    expect(text('profile-current-weight'), '61,5');
    // Two separators or two decimals are refused; the last value stays.
    await _enter(tester, 'profile-current-weight', '6,1,5');
    expect(text('profile-current-weight'), '61,5');
    await _enter(tester, 'profile-current-weight', '61,55');
    expect(text('profile-current-weight'), '61,5');
    await _enter(tester, 'profile-height', '165.5');
    expect(text('profile-height'), '165.5');
    // Age takes whole numbers only, at most three digits.
    await _enter(tester, 'profile-age', '3a2');
    expect(text('profile-age'), '32');
    await _enter(tester, 'profile-age', '1234');
    expect(text('profile-age'), '123');
    await _continue(tester);
    expect(find.text('Tuổi chưa hợp lệ'), findsOneWidget);
    await _enter(tester, 'profile-age', '12');
    await _continue(tester);
    expect(find.text('Lành dành cho người từ 13 tuổi'), findsOneWidget);
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

Future<void> _sitting(WidgetTester tester) async {
  final tile = find.byKey(const Key('profile-activity-sitting'));
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
  await _continue(tester);
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('profile-setup-action')));
  await tester.pumpAndSettle();
}

Future<void> _chooseGoal(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await _continue(tester);
}

void _expectTile(int index, String value) => expect(
  find.descendant(
    of: find.byKey(Key('profile-plan-tile-$index')),
    matching: find.text(value),
  ),
  findsOneWidget,
);

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

Future<void> _fillBody(
  WidgetTester tester, {
  String age = '32',
  String height = '160',
  required String weight,
  bool female = true,
}) async {
  await _enter(tester, 'profile-age', age);
  await _enter(tester, 'profile-height', height);
  await _enter(tester, 'profile-current-weight', weight);
  FocusManager.instance.primaryFocus?.unfocus();
  final sex = find.byKey(Key('profile-sex-${female ? 'female' : 'male'}'));
  await tester.ensureVisible(sex);
  await tester.pumpAndSettle();
  await tester.tap(sex);
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
