import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/meal_logging/data/device_meal_voice_recognizer.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_voice_recognizer.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_voice_flow.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/test_meal_voice_recognizer.dart';

/// Device check of voice logging. Build with
/// `--dart-define=LANH_MEAL_API_BASE_URL=http://<mac-lan-ip>:8080`.
/// The real recognizer shows the system prompt on the recording screen; the
/// API call uses a typed description, so no microphone input is needed.
/// Nothing is saved.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final artifacts = Directory('${Directory.systemTemp.path}/meal-voice');
  final notes = <String, Object?>{};
  var surfaceConverted = false;
  setUp(() => surfaceConverted = false);
  final reportOriginal = reportTestException;
  reportTestException = (details, description) {
    // Keep the failure text in results.json; Profile builds have no console.
    notes['error:$description'] =
        '${details.exceptionAsString()}\n${details.stack.toString().split('\n').take(8).join('\n')}';
    reportOriginal(details, description);
  };
  tearDownAll(() async {
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/results.json').writeAsString(
      jsonEncode({
        'runId': const String.fromEnvironment('LANH_DEVICE_RUN_ID'),
        'finishedAt': DateTime.now().toUtc().toIso8601String(),
        'passed':
            binding.results.isNotEmpty && binding.failureMethodsDetails.isEmpty,
        'results': binding.results.map(
          (name, result) => MapEntry(name, '$result'),
        ),
        'notes': notes,
        'apiConfigured': mealApiBaseUri() != null,
        'osVersion': Platform.operatingSystemVersion,
      }),
    );
  });

  Future<void> screenshot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 300));
    final bytes = await binding.takeScreenshot(name);
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/$name.png').writeAsBytes(bytes);
  }

  Future<void> mount(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const MealVoiceFlow(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    if (Platform.isAndroid && !surfaceConverted) {
      await binding.convertFlutterSurfaceToImage();
      surfaceConverted = true;
      await tester.pump();
    }
  }

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) fail('Timed out: $finder');
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 500));
  }

  Finder anyText(Set<String> texts) => find.byWidgetPredicate(
    (widget) => widget is Text && texts.contains(widget.data),
  );

  const description = 'Ăn một tô phở bò tái, thêm ly trà đá';

  testWidgets('the real recognizer asks for access on the recording screen', (
    tester,
  ) async {
    await mount(tester);
    // The native Speech/microphone prompt is modal and cannot be answered
    // from Flutter; an unanswered prompt keeps the screen in "opening".
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    String state() =>
        find.text('Chạm để dừng và kiểm tra chữ').evaluate().isNotEmpty
        ? 'listening'
        : find.text('Lành chưa được dùng micro').evaluate().isNotEmpty
        ? 'denied'
        : find.text('Đang mở micro…').evaluate().isNotEmpty
        ? 'prompting'
        : 'other';
    while (DateTime.now().isBefore(deadline) && state() == 'prompting') {
      await tester.pump(const Duration(milliseconds: 250));
    }
    notes['realAccess'] = state();
    expect(find.text('Cho Lành dùng micro?'), findsNothing);
    expect(find.text('Ghi giọng nói'), findsOneWidget);
    expect(state(), isNot('other'));
    await screenshot(tester, 'iphone-voice-real-access');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('refused access, typed text, real API estimate', (tester) async {
    expect(mealApiBaseUri(), isNotNull, reason: 'LANH_MEAL_API_BASE_URL');
    final voice = TestMealVoiceRecognizer(status: MealVoiceAccess.denied);
    await mount(
      tester,
      overrides: [mealVoiceRecognizerProvider.overrideWithValue(voice)],
    );
    await waitFor(tester, find.text('Lành chưa được dùng micro'));
    expect(find.byKey(const Key('meal-voice-settings')), findsOneWidget);
    await screenshot(tester, 'iphone-voice-denied-inline');

    if (find.text('Kiểm tra lời nói').evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('meal-voice-type')));
      await tester.pumpAndSettle();
    }
    // The device IME echoes its own state over tester.enterText, so set the
    // field's controller, which drives the same listener as typing.
    tester
            .widget<TextField>(find.byKey(const Key('meal-voice-text')))
            .controller!
            .text =
        description;
    await tester.pumpAndSettle();
    await screenshot(tester, 'iphone-voice-typed');
    expect(find.text('10 từ'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    // Wait until the keyboard is gone so the dock stops moving before tapping.
    final keyboardDeadline = DateTime.now().add(const Duration(seconds: 5));
    while (tester.view.viewInsets.bottom > 0 &&
        DateTime.now().isBefore(keyboardDeadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 600));

    final send = find.byKey(const Key('meal-voice-send'));
    notes['beforeSend'] = {
      'insets': tester.view.viewInsets.bottom,
      'sendRect': '${tester.getRect(send)}',
      'enabled': tester.widget<AppButton>(send).onPressed != null,
    };
    final watch = Stopwatch()..start();
    await tester.tap(send);
    await tester.pump(const Duration(milliseconds: 400));
    // A fast service can answer before the waiting screen is seen; either
    // the waiting screen or the finished estimate is a valid next state.
    final waiting = find.text('Đã nhận lời kể').evaluate().isNotEmpty;
    notes['sawWaitingScreen'] = waiting;
    if (waiting) {
      await screenshot(tester, 'iphone-voice-estimating');
    } else {
      notes['afterSendTexts'] = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .whereType<String>()
          .take(20)
          .toList();
      await screenshot(tester, 'iphone-voice-after-send');
    }
    await waitFor(tester, anyText({'Kiểm tra bữa ăn', 'Chưa ước lượng được'}));
    watch.stop();
    notes['estimateMilliseconds'] = watch.elapsedMilliseconds;
    if (find.text('Chưa ước lượng được').evaluate().isNotEmpty) {
      await screenshot(tester, 'iphone-voice-estimation-error');
      fail('Text estimate failed on device.');
    }
    expect(find.byKey(const Key('meal-analysis-total')), findsOneWidget);
    await screenshot(tester, 'iphone-voice-result');
    await tester.scrollUntilVisible(
      find.text('Các món'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await screenshot(tester, 'iphone-voice-result-items');
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('meal-analysis-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('meal-analysis-back')));
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('scripted session: waveform, live-text morph, re-record', (
    tester,
  ) async {
    final voice = TestMealVoiceRecognizer();
    await mount(
      tester,
      overrides: [mealVoiceRecognizerProvider.overrideWithValue(voice)],
    );
    await waitFor(tester, find.text('Chạm để dừng và kiểm tra chữ'));

    // Real frame timings from the engine, excluding screenshot pauses.
    final timings = <FrameTiming>[];
    var measuring = true;
    void collect(List<FrameTiming> frames) {
      if (measuring) timings.addAll(frames);
    }

    SchedulerBinding.instance.addTimingsCallback(collect);
    Future<void> shot(String name) async {
      measuring = false;
      await screenshot(tester, name);
      measuring = true;
    }

    // Levels measured on this iPhone: room noise 0.12–0.19, speech higher;
    // the plugin reports about ten times a second.
    var level = 0.15;
    Future<void> speak(int from, int to, {bool silent = false}) async {
      for (var frame = from; frame < to; frame++) {
        if (frame % 3 == 0) {
          final t = frame / 30;
          level = silent
              ? 0.13 + 0.05 * ((frame * 7) % 10) / 10
              : 0.2 +
                    0.45 *
                        (0.5 + 0.5 * math.sin(t * 9)) *
                        (0.6 + 0.4 * math.sin(t * 1.3));
          voice.level(level);
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    await speak(0, 90, silent: true);
    await shot('iphone-voice-silence');
    await speak(90, 180);
    measuring = false;
    await File('${artifacts.path}/iphone-voice-speaking.png')
        .writeAsBytes(await binding.takeScreenshot('iphone-voice-speaking'));
    measuring = true;

    // First words: filmstrip of the morph, slowed 6x (test only) so the
    // in-between frames can be captured; frame timing is paused meanwhile.
    measuring = false;
    timeDilation = 6;
    voice.hear('Ăn một tô phở bò');
    await tester.pump();
    for (var index = 0; index < 5; index++) {
      await File(
        '${artifacts.path}/iphone-voice-morph-$index.png',
      ).writeAsBytes(await binding.takeScreenshot('iphone-voice-morph-$index'));
      await speak(0, 40);
    }
    timeDilation = 1;
    measuring = true;
    await speak(200, 300);
    voice.hear('Ăn một tô phở bò tái, thêm ly trà');
    await speak(300, 380);
    // Capture mid-speech, without the settle pause, so the meters are live.
    measuring = false;
    await File('${artifacts.path}/iphone-voice-live-text.png')
        .writeAsBytes(await binding.takeScreenshot('iphone-voice-live-text'));
    measuring = true;
    // Diagnostics: the pill meter's bar heights while speaking.
    for (final element in find.byType(CustomPaint).evaluate()) {
      final painter = (element.widget as CustomPaint).painter;
      try {
        final heights = (painter as dynamic).wave.heights as List<double>;
        if (heights.length == 5) {
          notes['miniWave'] = heights.map((h) => h.toStringAsFixed(2)).toList();
        }
      } on NoSuchMethodError {
        // Not a waveform painter.
      }
    }
    expect(find.byKey(const Key('meal-voice-live-text')), findsOneWidget);
    expect(find.byKey(const Key('meal-voice-timer')), findsNothing);

    await tester.tap(find.byKey(const Key('meal-voice-record')));
    await tester.pump(const Duration(milliseconds: 300));
    await shot('iphone-voice-finishing');
    voice.hear(description, isFinal: true);
    await voice.finish();
    await waitFor(tester, find.text('Lành nghe rồi'));
    await tester.pumpAndSettle();
    await shot('iphone-voice-confirm');

    // Recording again: the waveform returns, spreading from the centre.
    await tester.tap(find.byKey(const Key('meal-voice-record-again')));
    await tester.pump();
    await speak(0, 8, silent: true);
    await shot('iphone-voice-rerecord-0');
    await speak(8, 45, silent: true);
    await shot('iphone-voice-rerecord-1');
    expect(find.byKey(const Key('meal-voice-live-text')), findsNothing);

    SchedulerBinding.instance.removeTimingsCallback(collect);
    double ms(Duration d) => d.inMicroseconds / 1000;
    final build = timings.map((t) => ms(t.buildDuration)).toList()..sort();
    final raster = timings.map((t) => ms(t.rasterDuration)).toList()..sort();
    double pct(List<double> v, double q) =>
        v.isEmpty ? -1 : v[((v.length - 1) * q).round()];
    notes['frames'] = {
      'count': timings.length,
      'buildP50': pct(build, 0.5),
      'buildP90': pct(build, 0.9),
      'buildMax': pct(build, 1),
      'rasterP50': pct(raster, 0.5),
      'rasterP90': pct(raster, 0.9),
      'rasterMax': pct(raster, 1),
      'over16ms': timings
          .where(
            (t) => ms(t.buildDuration) > 16.7 || ms(t.rasterDuration) > 16.7,
          )
          .length,
    };
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an unreachable server keeps the description for retry', (
    tester,
  ) async {
    final base = mealApiBaseUri()!;
    final voice = TestMealVoiceRecognizer();
    await mount(
      tester,
      overrides: [
        mealVoiceRecognizerProvider.overrideWithValue(voice),
        mealAnalysisRepositoryProvider.overrideWithValue(
          HttpMealAnalysisRepository(
            baseUri: base.replace(port: 9),
            timeout: const Duration(seconds: 20),
          ),
        ),
      ],
    );
    await waitFor(tester, find.text('Chạm để dừng và kiểm tra chữ'));
    voice.hear(description, isFinal: true);
    await voice.finish();
    await waitFor(tester, find.byKey(const Key('meal-voice-send')));
    await tester.tap(find.byKey(const Key('meal-voice-send')));
    await waitFor(tester, find.text('Chưa ước lượng được'));
    expect(find.textContaining('Lời kể vẫn được giữ lại'), findsOneWidget);
    await screenshot(tester, 'iphone-voice-network-error');
    await tester.tap(find.text('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('measures the real microphone level range', (tester) async {
    // Only loudness numbers are kept; no audio or transcript is stored.
    final recognizer = DeviceMealVoiceRecognizer();
    if (await recognizer.access() != MealVoiceAccess.granted) {
      notes['levels'] = 'no access';
      return;
    }
    final levels = <double>[];
    final sub = recognizer.listen(languageCode: 'vi').listen((event) {
      if (event is MealVoiceLevel) levels.add(event.level);
    });
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 6)),
    );
    await recognizer.cancel();
    await sub.cancel();
    levels.sort();
    double at(double q) =>
        levels.isEmpty ? -1 : levels[((levels.length - 1) * q).round()];
    notes['levels'] = {
      'count': levels.length,
      'min': at(0),
      'p10': at(0.1),
      'p50': at(0.5),
      'p90': at(0.9),
      'max': at(1),
    };
  });
}
