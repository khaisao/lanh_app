import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/app/app.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_camera.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_flow.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_image.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:lanh_app/features/profile_setup/profile_setup_providers.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_goal_repository.dart';
import 'support/test_onboarding_repository.dart';
import 'support/test_profile_repository.dart';

const _cameraOption = Key('meal-method-camera');
const _library = 'Chọn ảnh từ thư viện';
const _allow = 'Cho phép camera';
const _estimate = 'Ước lượng bữa ăn';
final _photo = MealPhoto(
  File('assets/design/images/dzdAuAChai1.jpeg').readAsBytesSync(),
);

void main() {
  final captureDirectory = Platform.environment['LANH_PREVIEW_DIR'];
  setUpAll(() async {
    if (captureDirectory == null) return;
    await (FontLoader(AppFonts.body)
          ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/BeVietnamPro-SemiBold.ttf')))
        .load();
    await (FontLoader(
      AppFonts.heading,
    )..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'))).load();
  });

  for (final size in [
    const Size(320, 700),
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    testWidgets('captures, reviews and retakes at ${size.width} dp', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _PhotoRepository();
      final camera = _Camera();
      await _mount(tester, repository, camera);
      await _openFromHome(tester);
      expect(repository.requests, 0);
      expect(find.text('Cho Lành dùng camera?'), findsOneWidget);
      if (captureDirectory != null && size.width == 390) {
        await _capture(tester, captureDirectory, 'permission');
      }

      repository.requestResult = MealCameraAccess.granted;
      await _tap(tester, find.text(_allow));
      expect(repository.requests, 1);
      expect(find.byKey(const Key('live-camera')), findsOneWidget);
      final shutter = find.byTooltip('Chụp ảnh');
      expect(tester.getSize(shutter).width, 80);
      expect(tester.getSize(shutter).height, 80);
      final switchCamera = find.byTooltip('Đổi sang camera trước hoặc sau');
      expect(tester.getSize(switchCamera), const Size.square(56));
      expect(
        tester.getCenter(switchCamera).dx,
        greaterThan(tester.getCenter(shutter).dx),
      );
      final glassSizes = find
          .byType(AppMediaGlass)
          .evaluate()
          .map((element) => (element.renderObject! as RenderBox).size)
          .toList();
      expect(
        glassSizes.where((size) => size == const Size.square(48)).length,
        2,
      );
      expect(
        glassSizes.where((size) => size == const Size.square(44)).length,
        1,
      );
      if (captureDirectory != null && size.width == 390) {
        await _capture(tester, captureDirectory, 'camera');
      }
      await _tap(tester, shutter);
      expect(camera.captures, 1);
      expect(camera.closed, 1);
      expect(find.text('Chụp lại'), findsOneWidget);
      expect(find.bySemanticsLabel('Ảnh bữa ăn đang xem lại'), findsOneWidget);
      if (captureDirectory != null && size.width == 390) {
        await _capture(tester, captureDirectory, 'review');
      }

      await _tap(tester, find.text(_estimate));
      expect(
        find.text('Tính năng ước lượng bữa ăn chưa khả dụng.'),
        findsOneWidget,
      );
      await _tap(tester, find.text('Đóng').last);
      await _tap(tester, find.text('Chụp lại'));
      expect(find.byKey(const Key('live-camera')), findsOneWidget);
      await _tap(tester, find.byTooltip('Đóng').first);
      expect(find.byKey(_cameraOption), findsNothing);
      expect(find.byKey(const Key('nav-log-meal')), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('large text remains usable on ${platform.name}', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repository = _PhotoRepository();
      await _mount(tester, repository, _Camera());
      await _openFromHome(tester);
      repository.selected = _photo;
      await _tap(tester, find.text(_library));
      await _tap(tester, find.text(_estimate));
      await _tap(tester, find.text('Đóng').last);
      await _tap(tester, find.byTooltip('Quay lại'));
      expect(find.text(_allow), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('capture shows progress until the photo is ready', (
    tester,
  ) async {
    final repository = _PhotoRepository()..access = MealCameraAccess.granted;
    final pending = Completer<MealPhoto>();
    final camera = _Camera()..captureGate = pending;
    await _mount(tester, repository, camera);
    await _openFromHome(tester);
    await tester.tap(find.byTooltip('Chụp ảnh'));
    await tester.pump();
    expect(find.text('Đang chụp ảnh…'), findsOneWidget);
    final shutter = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Đang chụp ảnh…',
      ),
    );
    expect(shutter.onPressed, isNull);
    expect(camera.captures, 1);
    expect(find.text(_estimate), findsNothing);
    pending.complete(_photo);
    await tester.pumpAndSettle();
    expect(find.text(_estimate), findsOneWidget);
    expect(find.text('Đang chụp ảnh…'), findsNothing);
  });

  testWidgets('closing during capture discards the late result', (
    tester,
  ) async {
    final repository = _PhotoRepository()..access = MealCameraAccess.granted;
    final pending = Completer<MealPhoto>();
    final camera = _Camera()..captureGate = pending;
    await _mount(tester, repository, camera);
    await _openFromHome(tester);
    await tester.tap(find.byTooltip('Chụp ảnh'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(camera.closed, 1);
    pending.complete(_photo);
    await tester.pumpAndSettle();
    expect(find.byKey(_cameraOption), findsNothing);
    expect(find.byKey(const Key('nav-log-meal')), findsOneWidget);
    expect(find.text(_estimate), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'restricted camera still offers library and recovers a failed pick',
    (tester) async {
      final repository = _PhotoRepository()
        ..access = MealCameraAccess.restricted
        ..failPick = true;
      await _mount(tester, repository, _Camera());
      await _openFromHome(tester);
      expect(find.text(_allow), findsNothing);
      expect(find.text('Mở Cài đặt'), findsNothing);
      await _tap(tester, find.text(_library));
      expect(find.textContaining('Lành chưa mở được ảnh này'), findsOneWidget);
      await _tap(tester, find.text('Đóng').last);
      repository
        ..failPick = false
        ..selected = _photo;
      await _tap(tester, find.text(_library));
      expect(find.text(_estimate), findsOneWidget);
      expect(repository.requests, 0);
    },
  );

  testWidgets(
    'denial leaves picker available and Settings can restore camera',
    (tester) async {
      final repository = _PhotoRepository();
      await _mount(tester, repository, _Camera());
      await _openFromHome(tester);
      await _tap(tester, find.text(_allow));
      expect(find.textContaining('Bạn chưa cấp quyền camera'), findsOneWidget);

      await _tap(tester, find.text(_library));
      expect(find.text(_allow), findsOneWidget);
      repository.selected = _photo;
      await _tap(tester, find.text(_library));
      expect(repository.requests, 1);
      expect(find.text(_estimate), findsOneWidget);
      repository.selected = null;
      await _tap(tester, find.text('Chọn ảnh khác'));
      expect(find.text(_estimate), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(_allow), findsOneWidget);
      repository.requestResult = MealCameraAccess.blocked;
      await _tap(tester, find.text(_allow));
      await _tap(tester, find.text('Mở Cài đặt'));
      expect(repository.settingsOpened, 1);
      repository.access = MealCameraAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('live-camera')), findsOneWidget);
    },
  );

  testWidgets('camera reopens on resume and after picker cancellation', (
    tester,
  ) async {
    final repository = _PhotoRepository()..access = MealCameraAccess.granted;
    final camera = _Camera();
    await _mount(tester, repository, camera);
    await _openFromHome(tester);
    expect(find.text(_allow), findsNothing);
    expect(repository.requests, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(camera.closed, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live-camera')), findsOneWidget);

    await _tap(tester, find.byTooltip(_library));
    expect(camera.closed, 2);
    expect(find.byKey(const Key('live-camera')), findsOneWidget);
    repository.selected = _photo;
    await _tap(tester, find.byTooltip(_library));
    expect(find.text(_estimate), findsOneWidget);
    await _tap(tester, find.byTooltip('Quay lại'));
    expect(find.byKey(const Key('live-camera')), findsOneWidget);
  });

  testWidgets('restores an interrupted Android selection to photo review', (
    tester,
  ) async {
    final repository = _PhotoRepository()..recovered = _photo;
    await _mount(tester, repository, _Camera());
    expect(find.text(_estimate), findsOneWidget);
    expect(repository.requests, 0);
  });

  testWidgets(
    'recovery waits for foreground when Android recreates the app behind the picker',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      addTearDown(() {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });
      final repository = _PhotoRepository()..recovered = _photo;
      await _mount(tester, repository, _Camera());
      expect(repository.recoveries, 0);
      expect(find.text(_estimate), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repository.recoveries, 1);
      expect(find.text(_estimate), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repository.recoveries, 1);
    },
  );

  testWidgets(
    'a later resume recovers a result delivered after the first startup check',
    (tester) async {
      final repository = _PhotoRepository();
      await _mount(tester, repository, _Camera());
      final previousChecks = repository.recoveries;
      expect(previousChecks, greaterThan(0));
      repository.recovered = _photo;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repository.recoveries, previousChecks + 1);
      expect(find.text(_estimate), findsOneWidget);
    },
  );

  testWidgets(
    'resume does not consume picker recovery while a photo flow is active',
    (tester) async {
      final repository = _PhotoRepository()..access = MealCameraAccess.granted;
      await _mount(tester, repository, _Camera());
      await _openFromHome(tester);
      final previousChecks = repository.recoveries;
      repository.recovered = _photo;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(repository.recoveries, previousChecks);
      expect(repository.recovered, same(_photo));
      expect(find.byType(MealPhotoFlow), findsOneWidget);
    },
  );

  testWidgets(
    'recovery handles native image copying that finishes after resume',
    (tester) async {
      final repository = _PhotoRepository();
      await _mount(tester, repository, _Camera());
      final previousChecks = repository.recoveries;
      expect(previousChecks, greaterThan(0));
      repository.recovered = _photo;
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(repository.recoveries, previousChecks + 1);
      expect(find.text(_estimate), findsOneWidget);
    },
  );

  testWidgets('empty recovery checks stop after the bounded retry window', (
    tester,
  ) async {
    final repository = _PhotoRepository();
    await _mount(tester, repository, _Camera());
    for (var check = 0; check < 35; check++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(repository.recoveries, 31);
    await tester.pump(const Duration(seconds: 5));
    expect(repository.recoveries, 31);
  });

  testWidgets('unsupported platforms skip recovery checks', (tester) async {
    final repository = _PhotoRepository()..recoverySupported = false;
    await _mount(tester, repository, _Camera());
    await tester.pump(const Duration(seconds: 20));
    expect(repository.recoveries, 0);
  });

  testWidgets('repeated camera taps open one photo flow', (tester) async {
    await _mount(tester, _PhotoRepository(), _Camera());
    await _tap(tester, find.byKey(const Key('nav-log-meal')));
    final option = find.byKey(_cameraOption);
    await tester.tap(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(find.byType(MealPhotoFlow), findsOneWidget);
    await _tap(tester, find.text('Quay lại'));
    expect(find.byKey(_cameraOption), findsNothing);
    expect(find.byKey(const Key('nav-log-meal')), findsOneWidget);
  });

  testWidgets('switch control opens the other lens and captures its photo', (
    tester,
  ) async {
    final repository = _PhotoRepository()..access = MealCameraAccess.granted;
    final back = _Camera();
    final front = _Camera()..facing = MealCameraFacing.front;
    final pending = Completer<MealCamera>();
    await _mount(
      tester,
      repository,
      back,
      factory: (facing) =>
          facing == MealCameraFacing.back ? Future.value(back) : pending.future,
    );
    await _openFromHome(tester);
    await tester.tap(find.byTooltip('Đổi sang camera trước hoặc sau'));
    await tester.pump();
    expect(find.text('Đang đổi camera…'), findsOneWidget);
    expect(back.closed, 1);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Chụp ảnh'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Đổi sang camera trước hoặc sau'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
    pending.complete(front);
    await tester.pumpAndSettle();
    expect(find.text('Đang đổi camera…'), findsNothing);
    await _tap(tester, find.byTooltip('Chụp ảnh'));
    expect(front.captures, 1);
    expect(back.captures, 0);
    expect(find.text('Chụp lại'), findsOneWidget);
  });

  testWidgets('single-lens devices keep capture without a switch control', (
    tester,
  ) async {
    await _mount(
      tester,
      _PhotoRepository()..access = MealCameraAccess.granted,
      _Camera()..canSwitchFacing = false,
    );
    await _openFromHome(tester);
    expect(find.byTooltip('Đổi sang camera trước hoặc sau'), findsNothing);
    await _tap(tester, find.byTooltip('Chụp ảnh'));
    expect(find.text('Chụp lại'), findsOneWidget);
  });
}

Future<void> _mount(
  WidgetTester tester,
  _PhotoRepository repository,
  _Camera camera, {
  MealCameraFactory? factory,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(
          TestOnboardingRepository()..completed = true,
        ),
        goalRepositoryProvider.overrideWithValue(TestGoalRepository()),
        profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
        mealPhotoRepositoryProvider.overrideWithValue(repository),
        mealCameraFactoryProvider.overrideWithValue(
          factory ?? (facing) async => camera,
        ),
      ],
      child: const RepaintBoundary(
        key: Key('photo-flow-capture'),
        child: Application(),
      ),
    ),
  );
  await tester.runAsync(
    () => prepareMealPhoto(tester.element(find.byType(Application)), _photo),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(
  WidgetTester tester,
  String directory,
  String stage,
) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('photo-flow-capture')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$directory/meal-photo-$stage.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _openFromHome(WidgetTester tester) async {
  await _tap(tester, find.byKey(const Key('nav-log-meal')));
  await _tap(tester, find.byKey(_cameraOption));
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _PhotoRepository implements MealPhotoRepository {
  @override
  bool get supportsRecovery => recoverySupported;
  bool recoverySupported = true;
  MealCameraAccess access = MealCameraAccess.denied;
  MealCameraAccess requestResult = MealCameraAccess.denied;
  MealPhoto? selected;
  MealPhoto? recovered;
  int requests = 0;
  int settingsOpened = 0;
  int recoveries = 0;
  bool failPick = false;

  @override
  Future<MealCameraAccess> cameraAccess({bool request = false}) async {
    if (request) {
      requests++;
      access = requestResult;
    }
    return access;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Future<MealPhoto?> pickPhoto() async {
    if (failPick) throw StateError('Photo selection failed.');
    return selected;
  }

  @override
  Future<MealPhoto?> recoverPickedPhoto() async {
    recoveries++;
    final selection = recovered;
    recovered = null;
    return selection;
  }
}

class _Camera implements MealCamera {
  @override
  MealCameraFacing facing = MealCameraFacing.back;
  @override
  bool canSwitchFacing = true;
  Completer<MealPhoto>? captureGate;
  int captures = 0;
  int closed = 0;

  @override
  Widget preview() =>
      const ColoredBox(key: Key('live-camera'), color: Colors.black);

  @override
  Future<MealPhoto> capture() async {
    captures++;
    if (captureGate != null) return captureGate!.future;
    return _photo;
  }

  @override
  Future<void> close() async => closed++;
}
