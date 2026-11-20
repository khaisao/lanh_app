import 'dart:async';
import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_voice_recognizer.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_method_sheet.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_voice_flow.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_meal_analysis_repository.dart';
import 'support/test_meal_voice_recognizer.dart';

late TestMealVoiceRecognizer _voice;
late TestMealAnalysisRepository _analysis;

Future<void> _mount(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduceMotion = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _voice = TestMealVoiceRecognizer();
  _analysis = TestMealAnalysisRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mealVoiceRecognizerProvider.overrideWithValue(_voice),
        mealAnalysisRepositoryProvider.overrideWithValue(_analysis),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        // Reduce Motion stops the looping listening animations.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => unawaited(showMealMethodSheet(context)),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _openVoice(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('meal-method-voice')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('meal-method-voice')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('records, confirms the text and sends only that text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _mount(tester);
    expect(find.text('Ghi bằng giọng nói · Sắp có'), findsNothing);
    await _openVoice(tester);

    expect(_voice.listening, isTrue);
    expect(_voice.languages, ['vi']);
    expect(find.text('Ghi giọng nói'), findsOneWidget);
    expect(find.text('Đang ghi âm'), findsOneWidget);
    expect(find.text('Kể tên món và lượng ăn'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Chạm để dừng và kiểm tra chữ'), findsOneWidget);
    expect(find.bySemanticsLabel('Dừng ghi âm'), findsOneWidget);
    // Before any words the waveform is the hero and no text is shown.
    expect(find.byKey(const Key('meal-voice-timer')), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-live-text')), findsNothing);

    _voice.hear('Ăn một tô phở bò tái');
    await tester.pump();
    await tester.pump();
    // A first partial result is still tentative (dimmed); words repeated by
    // the next result become stable.
    String live() => tester
        .widget<RichText>(
          find.descendant(
            of: find.byKey(const Key('meal-voice-live-text')),
            matching: find.byType(RichText),
          ),
        )
        .text
        .toPlainText();
    expect(live(), contains('Ăn một tô phở bò tái'));
    // Words replace the waveform: compact pill timer, big timer gone.
    expect(find.byKey(const Key('meal-voice-pill-timer')), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-timer')), findsNothing);
    _voice.hear('Ăn một tô phở bò tái, thêm ly trà');
    await tester.pump();
    await tester.pump();
    final spans = <String>[];
    tester
        .widget<RichText>(
          find.descendant(
            of: find.byKey(const Key('meal-voice-live-text')),
            matching: find.byType(RichText),
          ),
        )
        .text
        .visitChildren((span) {
          if (span is TextSpan && span.text != null) spans.add(span.text!);
          return true;
        });
    // The repeated prefix is stable; at most three new words stay dimmed.
    expect(spans.first, 'Ăn một tô phở bò tái,');
    expect(spans[1], ' thêm ly trà');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);

    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pump();
    expect(_voice.stops, 1);
    expect(find.text('Đang chuyển thành chữ…'), findsWidgets);
    _voice.hear('Ăn một tô phở bò tái, thêm ly trà đá', isFinal: true);
    await _voice.finish();
    await tester.pumpAndSettle();

    expect(find.text('Kiểm tra lời nói'), findsOneWidget);
    expect(find.text('Lành nghe xong rồi'), findsOneWidget);
    expect(find.text('10 từ'), findsOneWidget);
    expect(
      find.text('Chỉ chữ này được gửi lên Lành để ước lượng món.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('meal-voice-text')),
      'Ăn một tô phở bò tái',
    );
    await tester.pump();
    expect(find.text('6 từ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await tester.pump();
    expect(_analysis.descriptions, ['Ăn một tô phở bò tái']);
    expect(find.text('Lành đang ước lượng'), findsOneWidget);
    expect(find.text('Đã nhận lời kể'), findsOneWidget);
    // Without a Material ancestor Flutter draws the yellow warning underline.
    expect(
      find.ancestor(
        of: find.text('Lành đang ước lượng'),
        matching: find.byType(Material),
      ),
      findsWidgets,
    );

    _analysis.succeed();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-analysis-result')), findsOneWidget);
    expect(find.text('Cơm trắng'), findsWidgets);
    semantics.dispose();
  });

  testWidgets('estimation errors keep the text and retry the same request', (
    tester,
  ) async {
    await _mount(tester);
    await _openVoice(tester);
    _voice.hear('phở bò', isFinal: true);
    await _voice.finish();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await tester.pump();
    _analysis.fail();
    await tester.pumpAndSettle();
    expect(find.text('Chưa ước lượng được'), findsOneWidget);
    expect(find.textContaining('Lời kể vẫn được giữ lại'), findsOneWidget);

    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    expect(_analysis.requests.toSet(), hasLength(1));
    expect(_analysis.requests, hasLength(2));

    // System back from estimation returns to the same editable text.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_analysis.cancelled, hasLength(1));
    expect(find.text('phở bò'), findsOneWidget);
  });

  testWidgets('silence returns to the microphone with a reason', (
    tester,
  ) async {
    await _mount(tester);
    await _openVoice(tester);
    _voice.fail(MealVoiceFailureKind.noSpeech);
    await _voice.finish();
    await tester.pumpAndSettle();
    expect(
      find.text('Lành chưa nghe thấy lời nào. Chạm micro và kể lại nhé.'),
      findsOneWidget,
    );
    expect(find.text('Lành chưa nghe rõ'), findsOneWidget);
    expect(find.text('Chạm để bắt đầu nói'), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-caption')), findsNothing);

    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pumpAndSettle();
    expect(_voice.languages, hasLength(2));
  });

  for (final (name, close) in [
    ('Hủy ghi', const Key('meal-voice-cancel')),
    ('X', const Key('meal-voice-close')),
  ]) {
    testWidgets('$name stops recording and returns to the origin screen', (
      tester,
    ) async {
      await _mount(tester);
      await _openVoice(tester);
      // Choosing voice closes the picker; it stays closed afterwards.
      expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
      expect(_voice.listening, isTrue);
      await tester.tap(find.byKey(close));
      await tester.pumpAndSettle();
      expect(_voice.cancels, greaterThan(0));
      expect(find.byType(MealVoiceFlow), findsNothing);
      expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  }

  testWidgets('system back from recording returns to the origin screen', (
    tester,
  ) async {
    await _mount(tester);
    await _openVoice(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MealVoiceFlow), findsNothing);
    expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
  });

  testWidgets('voice access is requested on the picker before opening', (
    tester,
  ) async {
    await _mount(tester);
    _voice.status = MealVoiceAccess.denied;
    await _openVoice(tester);
    // Asked in place: the recording screen stays closed until allowed.
    expect(_voice.requests, 1);
    expect(find.byType(MealVoiceFlow), findsNothing);
    expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
    expect(find.text('Lành chưa được dùng micro'), findsOneWidget);
    expect(
      find.text('Bật quyền micro trong Cài đặt để ghi bữa ăn bằng giọng nói.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('meal-voice-access-settings')));
    await tester.pumpAndSettle();
    expect(_voice.settingsOpened, 1);
    expect(find.byKey(const Key('meal-voice-access-dialog')), findsNothing);
    expect(find.byType(MealVoiceFlow), findsNothing);

    // Allowed in Settings: the next tap opens the recording screen.
    _voice.status = MealVoiceAccess.granted;
    await _openVoice(tester);
    expect(_voice.requests, greaterThanOrEqualTo(2));
    expect(find.byType(MealVoiceFlow), findsOneWidget);
    expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
    expect(_voice.listening, isTrue);
  });

  testWidgets('closing the refusal notice keeps the picker open', (
    tester,
  ) async {
    await _mount(tester);
    _voice.status = MealVoiceAccess.denied;
    await _openVoice(tester);
    await tester.tap(find.byKey(const Key('meal-voice-access-close')));
    await tester.pumpAndSettle();
    expect(_voice.settingsOpened, 0);
    expect(find.byType(MealVoiceFlow), findsNothing);
    expect(find.byKey(const Key('meal-method-sheet')), findsOneWidget);
  });

  testWidgets('a device without a recognizer stays on the picker', (
    tester,
  ) async {
    await _mount(tester);
    _voice.status = MealVoiceAccess.unavailable;
    await _openVoice(tester);
    expect(find.byType(MealVoiceFlow), findsNothing);
    expect(
      find.text('Thiết bị này chưa hỗ trợ ghi giọng nói.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('meal-voice-access-settings')), findsNothing);
  });

  testWidgets('access refused later is explained on the recording screen', (
    tester,
  ) async {
    await _mount(tester);
    // Granted on the picker, then withdrawn before the screen asks again.
    _voice.requestAnswers.addAll([
      MealVoiceAccess.granted,
      MealVoiceAccess.denied,
    ]);
    await _openVoice(tester);
    expect(find.byType(MealVoiceFlow), findsOneWidget);
    expect(find.text('Lành chưa được dùng micro'), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-settings')), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-voice-type')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('meal-voice-text')), 'bún chả');
    await tester.pump();
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await tester.pump();
    expect(_analysis.descriptions, ['bún chả']);
  });

  for (final size in [
    const Size(320, 700),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    testWidgets('fits ${size.width} dp with 200% text', (tester) async {
      await _mount(tester, size: size, textScale: 2);
      await _openVoice(tester);
      expect(tester.takeException(), isNull);
      _voice.hear('Ăn một tô phở bò tái, thêm ly trà đá', isFinal: true);
      await _voice.finish();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('meal-voice-send')), findsOneWidget);
    });
  }

  testWidgets('typing with the keyboard open keeps the send action usable', (
    tester,
  ) async {
    await _mount(tester, size: const Size(428, 926));
    await _openVoice(tester);
    await _voice.finish();
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 346);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(find.byKey(const Key('meal-voice-type')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const Key('meal-voice-text')),
      'Ăn một tô phở bò tái, thêm ly trà đá',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('10 từ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await tester.pump();
    expect(_analysis.descriptions, hasLength(1));
  });

  testWidgets('the waveform follows the voice and settles after stopping', (
    tester,
  ) async {
    await _mount(tester, reduceMotion: false);
    await tester.ensureVisible(find.byKey(const Key('meal-method-voice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-method-voice')));
    // Listening animations never settle, so pump the route transition.
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_voice.listening, isTrue);
    for (var frame = 0; frame < 90; frame++) {
      _voice.level(frame.isEven ? 0.8 : 0.3);
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('meal-voice-record')));
    _voice.hear('phở bò', isFinal: true);
    await _voice.finish();
    // No animation keeps running once the recording screen is left.
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra lời nói'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('first words morph the waveform into the live-text layout', (
    tester,
  ) async {
    await _mount(tester, reduceMotion: false);
    await tester.ensureVisible(find.byKey(const Key('meal-method-voice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-method-voice')));
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byKey(const Key('meal-voice-timer')), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-live-text')), findsNothing);
    final wave = find.descendant(
      of: find.byKey(const Key('meal-voice-wave-entrance')),
      matching: find.byType(CustomPaint),
    );
    final waveElement = tester.element(wave);
    expect(tester.getSize(wave).height, 128);
    final statusTop = tester
        .getTopLeft(find.byKey(const Key('meal-voice-status')))
        .dy;

    _voice.hear('Ăn một tô phở bò');
    await tester.pump();
    // Sample the band frame by frame: it must rise gently, never jump.
    final waveTops = <double>[tester.getTopLeft(wave).dy];
    var sawBoth = false;
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      waveTops.add(tester.getTopLeft(wave).dy);
      sawBoth |=
          find.byKey(const Key('meal-voice-timer')).evaluate().isNotEmpty &&
          find.byKey(const Key('meal-voice-live-text')).evaluate().isNotEmpty;
    }
    // Mid-morph both states are on screen, crossing over.
    expect(sawBoth, isTrue);
    var largestStep = 0.0;
    for (var i = 1; i < waveTops.length; i++) {
      largestStep = math.max(
        largestStep,
        (waveTops[i] - waveTops[i - 1]).abs(),
      );
    }
    expect(largestStep, lessThan(6));
    final settledAt = waveTops.indexWhere((top) => top == waveTops.last);
    expect(settledAt * 16, greaterThanOrEqualTo(600));
    double opacityOf(Key key) => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.byKey(key), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    expect(find.byKey(const Key('meal-voice-timer')), findsNothing);
    expect(opacityOf(const Key('meal-voice-live-text')), 1);
    expect(find.byKey(const Key('meal-voice-pill-timer')), findsOneWidget);
    // The same waveform thins into the 40 dp band; it is never rebuilt.
    expect(tester.getSize(wave).height, 40);
    expect(identical(tester.element(wave), waveElement), isTrue);
    // The status row stays put while the rest moves.
    expect(
      tester.getTopLeft(find.byKey(const Key('meal-voice-status'))).dy,
      closeTo(statusTop, 1),
    );
    // Words are left-aligned and centred in the space below the band.
    final words = find.byKey(const Key('meal-voice-live-text'));
    final bandBottom = tester.getBottomLeft(wave).dy;
    final dock = tester
        .getTopLeft(find.byKey(const Key('meal-voice-record')))
        .dy;
    final wordsCentre = tester.getCenter(words).dy;
    expect(wordsCentre, greaterThan(bandBottom));
    expect(wordsCentre, lessThan(dock));
    expect(
      tester.getTopLeft(words).dx,
      closeTo(tester.getTopLeft(wave).dx + AppSpacing.pageHorizontal - 24, 24),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('meal-voice-record')));
    _voice.hear('phở bò', isFinal: true);
    await _voice.finish();
    // No animation keeps running once the recording screen is left.
    await tester.pumpAndSettle();
    expect(find.text('Kiểm tra lời nói'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);

    // Recording again brings the waveform back, spreading from the centre.
    await tester.tap(find.byKey(const Key('meal-voice-record-again')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    double waveOpacity() => tester
        .widget<Opacity>(find.byKey(const Key('meal-voice-wave-entrance')))
        .opacity;
    expect(find.byKey(const Key('meal-voice-live-text')), findsNothing);
    expect(waveOpacity(), inExclusiveRange(0, 1));
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(waveOpacity(), 1);
    expect(tester.getSize(wave).height, 128);
    expect(tester.takeException(), isNull);
  });
}
