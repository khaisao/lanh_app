import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_method_sheet.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_flow.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'photo route covers the old page during ${platform.name} transition',
      (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const captureKey = Key('transition-capture');
        await tester.runAsync(AppBackground.preload);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mealPhotoRepositoryProvider.overrideWithValue(_Repository()),
            ],
            child: RepaintBoundary(
              key: captureKey,
              child: MaterialApp(
                theme: AppTheme.light(),
                locale: const Locale('vi'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                home: Builder(
                  builder: (context) => ColoredBox(
                    color: const Color(0xFFFF0000),
                    child: Scaffold(
                      body: Center(
                        child: AppButton(
                          onPressed: () =>
                              unawaited(showMealMethodSheet(context)),
                          child: const Text('Open meal methods'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open meal methods'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('close-meal-sheet')));
        await tester.pumpAndSettle();
        final homeContext = tester.element(find.text('Open meal methods'));
        unawaited(showMealPhotoFlow(homeContext));
        for (var frame = 0; frame < 4; frame++) {
          await tester.pump();
        }
        final route = ModalRoute.of(
          tester.element(find.byType(MealPhotoFlow)),
        )!;
        await tester.pump(
          Duration(
            microseconds: (route.transitionDuration.inMicroseconds * 0.9)
                .round(),
          ),
        );
        expect(route.animation!.status, AnimationStatus.forward);

        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(captureKey),
          );
          final image = await boundary.toImage();
          try {
            final pixels = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            final offset = (200 * image.width + 8) * 4;
            // A transparent incoming page exposes the pure red source at this spot.
            expect(pixels!.getUint8(offset + 1), greaterThan(100));
            expect(pixels.getUint8(offset + 2), greaterThan(100));
          } finally {
            image.dispose();
          }
        });
        await tester.pumpAndSettle();
        await tester.tap(find.text('Quay lại'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('meal-method-sheet')), findsNothing);
        expect(find.text('Open meal methods'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _Repository implements MealPhotoRepository {
  @override
  bool get supportsRecovery => false;
  @override
  Future<MealCameraAccess> cameraAccess({bool request = false}) async =>
      MealCameraAccess.denied;

  @override
  Future<bool> openSettings() async => false;

  @override
  Future<MealPhoto?> pickPhoto() async => null;

  @override
  Future<MealPhoto?> recoverPickedPhoto() async => null;
}
