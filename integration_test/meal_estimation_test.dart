import 'dart:convert';
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_flow.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Device check against the real meal API. Build with
/// `--dart-define=LANH_MEAL_API_BASE_URL=http://<mac-lan-ip>:8080`.
/// The bundled photo is a test input only; nothing is saved.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final artifacts = Directory('${Directory.systemTemp.path}/meal-estimation');
  final timings = <int>[];
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
        'estimateMilliseconds': timings,
        'apiConfigured': mealApiBaseUri() != null,
        'platform': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
      }),
    );
  });

  Future<void> screenshot(WidgetTester tester, String name) async {
    // SVG decoding and the native raster thread can finish after the first frame.
    await tester.pump(const Duration(milliseconds: 300));
    final bytes = await binding.takeScreenshot(name);
    await artifacts.create(recursive: true);
    await File('${artifacts.path}/$name.png').writeAsBytes(bytes);
  }

  Future<void> mount(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    final bytes = await rootBundle.load(
      'assets/design/images/dzdAuAChai1.jpeg',
    );
    final photo = MealPhoto(bytes.buffer.asUint8List());
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
          home: AppBackground(child: MealPhotoFlow(recoveredPhoto: photo)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps real frames until [finder] appears or the API timeout passes.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 100));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
  }

  final estimate = find.byKey(const Key('meal-photo-estimate'));
  final result = find.text('Kiểm tra bữa ăn');
  final error = find.text('Chưa ước lượng được');

  testWidgets('photo is estimated by the real API and reviewed', (
    tester,
  ) async {
    expect(mealApiBaseUri(), isNotNull, reason: 'LANH_MEAL_API_BASE_URL');
    await mount(tester);
    await screenshot(tester, 'iphone-meal-photo-preview');

    // Cancelling keeps the photo and ignores the abandoned request.
    await tester.tap(estimate);
    await tester.pump();
    expect(find.text('Lành đang ước lượng'), findsOneWidget);
    // On a 402 pt phone the cancel action sits below the fold.
    await tester.ensureVisible(find.text('Dừng lại'));
    await tester.pump();
    await tester.tap(find.text('Dừng lại'));
    await tester.pumpAndSettle();
    expect(estimate, findsOneWidget);

    for (var run = 0; run < 3; run++) {
      final watch = Stopwatch()..start();
      await tester.tap(estimate);
      await tester.pump(const Duration(milliseconds: 300));
      if (run == 0) await screenshot(tester, 'iphone-meal-estimating');
      await waitFor(
        tester,
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == 'Kiểm tra bữa ăn' ||
                  widget.data == 'Chưa ước lượng được'),
        ),
      );
      watch.stop();
      if (error.evaluate().isNotEmpty) {
        await screenshot(tester, 'iphone-meal-estimation-error-run-$run');
        fail('Estimate $run failed on device.');
      }
      timings.add(watch.elapsedMilliseconds);
      expect(result, findsOneWidget);
      expect(find.byKey(const Key('meal-analysis-total')), findsOneWidget);
      if (run == 0) {
        await screenshot(tester, 'iphone-meal-analysis-result');
        await tester.tap(find.byKey(const Key('meal-portion-0.5')));
        await tester.pumpAndSettle();
        await screenshot(tester, 'iphone-meal-analysis-half');
        await tester.scrollUntilVisible(
          find.text('Các món'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await screenshot(tester, 'iphone-meal-analysis-items');
      }
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('meal-analysis-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('meal-analysis-back')));
      await tester.pumpAndSettle();
      expect(estimate, findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an unreachable server shows a retryable network error', (
    tester,
  ) async {
    final base = mealApiBaseUri()!;
    await mount(
      tester,
      overrides: [
        mealAnalysisRepositoryProvider.overrideWithValue(
          HttpMealAnalysisRepository(
            baseUri: base.replace(port: 9),
            timeout: const Duration(seconds: 20),
          ),
        ),
      ],
    );
    await tester.tap(estimate);
    await tester.pump();
    await waitFor(tester, error);
    expect(find.textContaining('máy chủ'), findsOneWidget);
    await screenshot(tester, 'iphone-meal-estimation-network-error');
    await tester.tap(find.byType(AppNavigationButton).first);
    await tester.pumpAndSettle();
    expect(estimate, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
