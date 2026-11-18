import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_camera.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_photo_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'support/test_meal_analysis_repository.dart';

void main() {
  final photo = MealPhoto(Uint8List.fromList([1]));

  testWidgets('estimation requires a photo in review', (tester) async {
    final analysis = TestMealAnalysisRepository();
    final controller = MealPhotoController(
      _Repository(),
      (_) async => _Camera(),
      isActive: false,
      analysis: analysis,
    );
    unawaited(controller.startEstimation());
    await tester.pump();
    expect(controller.stage, MealPhotoStage.checking);
    expect(analysis.requests, isEmpty);
    controller.dispose();
  });

  testWidgets('estimation failure, retry and result keep the same draft', (
    tester,
  ) async {
    final analysis = TestMealAnalysisRepository();
    final controller = MealPhotoController(
      _Repository(),
      (_) async => _Camera(),
      recoveredPhoto: photo,
      isActive: false,
      analysis: analysis,
    );
    unawaited(controller.startEstimation());
    expect(controller.stage, MealPhotoStage.estimating);
    unawaited(controller.startEstimation());
    expect(analysis.requests, hasLength(1));
    analysis.fail(MealAnalysisFailureKind.network);
    await tester.pump();
    expect(controller.stage, MealPhotoStage.estimationError);
    expect(controller.estimationFailure, MealAnalysisFailureKind.network);
    expect(controller.photo, same(photo));

    unawaited(controller.startEstimation());
    expect(controller.estimationFailure, isNull);
    analysis.succeed();
    await tester.pump();
    expect(controller.stage, MealPhotoStage.result);
    expect(analysis.requests, hasLength(2));
    expect(analysis.requests.toSet(), hasLength(1));
    expect(controller.analysis!.totalCalories(), 580);

    controller.selectPortion(0.5);
    expect(controller.portionScale, 0.5);
    expect(controller.analysis!.totalCalories(controller.portionScale), 290);
    controller.selectPortion(0.7);
    expect(controller.portionScale, 0.5);

    controller.returnToPhoto();
    expect(controller.stage, MealPhotoStage.review);
    expect(controller.analysis, isNull);
    expect(controller.photo, same(photo));
    controller.dispose();
  });

  testWidgets('cancelling ignores a late estimate and aborts the request', (
    tester,
  ) async {
    final analysis = TestMealAnalysisRepository();
    final controller = MealPhotoController(
      _Repository(),
      (_) async => _Camera(),
      recoveredPhoto: photo,
      isActive: false,
      analysis: analysis,
    );
    unawaited(controller.startEstimation());
    controller.returnToPhoto();
    await tester.pump();
    expect(analysis.cancelled, hasLength(1));
    analysis.succeed();
    await tester.pump();
    expect(controller.stage, MealPhotoStage.review);
    expect(controller.analysis, isNull);
    controller.dispose();
  });

  testWidgets('disposing estimation cancels its pending notification', (
    tester,
  ) async {
    final analysis = TestMealAnalysisRepository();
    final controller = MealPhotoController(
      _Repository(),
      (_) async => _Camera(),
      recoveredPhoto: photo,
      isActive: false,
      analysis: analysis,
    );
    var notifications = 0;
    controller.addListener(() => notifications++);
    unawaited(controller.startEstimation());
    final beforeDispose = notifications;
    controller.dispose();
    analysis.succeed();
    await tester.pump();
    expect(notifications, beforeDispose);
    expect(analysis.cancelled, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching releases the old camera and serializes user actions', (
    tester,
  ) async {
    final back = _Camera();
    final front = _Camera()..facing = MealCameraFacing.front;
    final opening = Completer<MealCamera>();
    final facings = <MealCameraFacing>[];
    int? closesBeforeOpening;
    final controller = MealPhotoController(
      _Repository(),
      (facing) {
        facings.add(facing);
        if (facing == MealCameraFacing.front) {
          closesBeforeOpening = back.closes;
          return opening.future;
        }
        return Future.value(back);
      },
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    unawaited(controller.switchCamera());
    await tester.pump();
    expect(controller.switchingCamera, isTrue);
    expect(closesBeforeOpening, 1);
    expect(controller.camera, isNull);
    await controller.switchCamera();
    await controller.capturePhoto();
    expect(facings, [MealCameraFacing.back, MealCameraFacing.front]);
    expect(back.captures, 0);
    opening.complete(front);
    await tester.pump();
    expect(controller.camera, same(front));
    expect(controller.busy, isFalse);

    front.captureResult = Future.value(photo);
    await controller.capturePhoto();
    await tester.pump();
    expect(controller.stage, MealPhotoStage.review);
    controller.returnFromReview();
    await tester.pump();
    expect(facings.last, MealCameraFacing.front);
    controller.setActive(false);
    await tester.pump();
    controller.setActive(true);
    await tester.pump();
    expect(facings.last, MealCameraFacing.front);
    await controller.switchCamera();
    expect(facings.last, MealCameraFacing.back);
    expect(controller.camera, same(back));
    controller.dispose();
    await tester.pump();
  });

  testWidgets(
    'a failed switch restores the previous lens and reports an error',
    (tester) async {
      final facings = <MealCameraFacing>[];
      final camera = _Camera()..captureResult = Future.value(photo);
      final controller = MealPhotoController(
        _Repository(),
        (facing) async {
          facings.add(facing);
          if (facing == MealCameraFacing.front) {
            throw StateError('Front unavailable');
          }
          return camera;
        },
        isActive: true,
        analysis: TestMealAnalysisRepository(),
      );
      await controller.checkAccess();
      await tester.pump();
      await controller.switchCamera();
      expect(facings, [
        MealCameraFacing.back,
        MealCameraFacing.front,
        MealCameraFacing.back,
      ]);
      expect(controller.issue, MealPhotoIssue.cameraSwitch);
      expect(controller.stage, MealPhotoStage.camera);
      expect(controller.busy, isFalse);
      await controller.capturePhoto();
      expect(controller.photo, same(photo));
      controller.dispose();
      await tester.pump();
    },
  );

  testWidgets('one available lens and an active capture cannot be switched', (
    tester,
  ) async {
    final pending = Completer<MealPhoto>();
    final camera = _Camera()
      ..canSwitchFacing = false
      ..captureResult = pending.future;
    var opens = 0;
    final controller = MealPhotoController(
      _Repository(),
      (facing) async {
        opens++;
        return camera;
      },
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    await controller.switchCamera();
    expect(opens, 1);
    camera.canSwitchFacing = true;
    unawaited(controller.capturePhoto());
    await controller.switchCamera();
    expect(opens, 1);
    pending.complete(photo);
    await tester.pump();
    await controller.switchCamera();
    expect(opens, 1);
    controller.dispose();
    await tester.pump();
  });

  testWidgets(
    'background during switching closes the stale lens on completion',
    (tester) async {
      final pending = Completer<MealCamera>();
      final old = _Camera();
      final stale = _Camera()..facing = MealCameraFacing.front;
      final fresh = _Camera()..facing = MealCameraFacing.front;
      var opens = 0;
      final controller = MealPhotoController(
        _Repository(),
        (facing) {
          opens++;
          return opens == 1
              ? Future.value(old)
              : opens == 2
              ? pending.future
              : Future.value(fresh);
        },
        isActive: true,
        analysis: TestMealAnalysisRepository(),
      );
      await controller.checkAccess();
      await tester.pump();
      unawaited(controller.switchCamera());
      await tester.pump();
      controller.setActive(false);
      controller.setActive(true);
      pending.complete(stale);
      await tester.pump();
      expect(old.closes, 1);
      expect(stale.closes, 1);
      expect(controller.camera, same(fresh));
      expect(controller.busy, isFalse);
      controller.dispose();
      await tester.pump();
    },
  );

  testWidgets('closing during switching releases the late session', (
    tester,
  ) async {
    final pending = Completer<MealCamera>();
    final old = _Camera();
    final late = _Camera()..facing = MealCameraFacing.front;
    final controller = MealPhotoController(
      _Repository(),
      (facing) =>
          facing == MealCameraFacing.back ? Future.value(old) : pending.future,
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    unawaited(controller.switchCamera());
    await tester.pump();
    controller.dispose();
    pending.complete(late);
    await tester.pump();
    expect(old.closes, 1);
    expect(late.closes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a hung capture recovers and ignores its late result', (
    tester,
  ) async {
    final pending = Completer<MealPhoto>();
    final first = _Camera()..captureResult = pending.future;
    final second = _Camera();
    var opens = 0;
    final controller = MealPhotoController(
      _Repository(),
      (facing) async => opens++ == 0 ? first : second,
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    expect(controller.camera, same(first));
    unawaited(controller.capturePhoto());
    expect(controller.capturing, isTrue);
    await controller.capturePhoto();
    expect(first.captures, 1);

    await tester.pump(MealPhotoController.captureTimeout);
    expect(controller.busy, isFalse);
    expect(controller.issue, MealPhotoIssue.captureTimeout);
    expect(first.closes, 1);
    expect(controller.camera, same(second));
    expect(opens, 2);

    pending.complete(photo);
    await tester.pump();
    expect(controller.stage, MealPhotoStage.camera);
    expect(controller.photo, isNull);
    controller.dispose();
    await tester.pump();
    expect(second.closes, 1);
  });

  testWidgets('background cancels a capture and cannot overwrite a new photo', (
    tester,
  ) async {
    final pending = Completer<MealPhoto>();
    final nextPhoto = MealPhoto(Uint8List.fromList([2]));
    final first = _Camera()..captureResult = pending.future;
    final second = _Camera()..captureResult = Future.value(nextPhoto);
    var opens = 0;
    final controller = MealPhotoController(
      _Repository(),
      (facing) async => opens++ == 0 ? first : second,
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    unawaited(controller.capturePhoto());
    controller.setActive(false);
    await tester.pump();
    expect(controller.busy, isFalse);
    expect(first.closes, 1);
    controller.setActive(true);
    await tester.pump();
    await controller.capturePhoto();
    await tester.pump();
    expect(controller.photo, same(nextPhoto));
    pending.complete(photo);
    await tester.pump();
    expect(controller.photo, same(nextPhoto));
    expect(controller.stage, MealPhotoStage.review);
    controller.dispose();
  });

  testWidgets('late initialization is closed after leaving the flow', (
    tester,
  ) async {
    final pending = Completer<MealCamera>();
    final camera = _Camera();
    final controller = MealPhotoController(
      _Repository(),
      (facing) => pending.future,
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    controller.dispose();
    pending.complete(camera);
    await tester.pump();
    expect(camera.closes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('background during initialization replaces the stale session', (
    tester,
  ) async {
    final pending = Completer<MealCamera>();
    final stale = _Camera();
    final fresh = _Camera();
    var opens = 0;
    final controller = MealPhotoController(
      _Repository(),
      (facing) => opens++ == 0 ? pending.future : Future.value(fresh),
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    controller.setActive(false);
    controller.setActive(true);
    pending.complete(stale);
    await tester.pump();
    expect(stale.closes, 1);
    expect(controller.camera, same(fresh));
    expect(opens, 2);
    controller.dispose();
    await tester.pump();
    expect(fresh.closes, 1);
  });

  testWidgets('unavailable camera returns to a recoverable permission screen', (
    tester,
  ) async {
    final controller = MealPhotoController(
      _Repository(),
      (facing) => Future.error(StateError('No cameras available')),
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    expect(controller.stage, MealPhotoStage.permission);
    expect(controller.access, MealCameraAccess.unavailable);
    expect(controller.camera, isNull);
    expect(controller.busy, isFalse);
    controller.dispose();
  });

  testWidgets('capture failure recreates a usable camera', (tester) async {
    final first = _Camera()..captureError = StateError('Capture failed');
    final second = _Camera()..captureResult = Future.value(photo);
    var opens = 0;
    final controller = MealPhotoController(
      _Repository(),
      (facing) async => opens++ == 0 ? first : second,
      isActive: true,
      analysis: TestMealAnalysisRepository(),
    );
    await controller.checkAccess();
    await tester.pump();
    await controller.capturePhoto();
    await tester.pump();
    expect(controller.issue, MealPhotoIssue.capture);
    expect(controller.camera, same(second));
    expect(first.closes, 1);
    await controller.capturePhoto();
    await tester.pump();
    expect(controller.photo, same(photo));
    controller.dispose();
  });

  testWidgets(
    'review waits for a decoded image and rejects unreadable photos',
    (tester) async {
      final decoded = Completer<void>();
      final camera = _Camera()..captureResult = Future.value(photo);
      final controller = MealPhotoController(
        _Repository(),
        (facing) async => camera,
        isActive: true,
        analysis: TestMealAnalysisRepository(),
        preparePhoto: (_) => decoded.future,
      );
      await controller.checkAccess();
      await tester.pump();
      unawaited(controller.capturePhoto());
      await tester.pump();
      expect(controller.capturing, isTrue);
      expect(controller.stage, MealPhotoStage.camera);
      expect(controller.photo, isNull);
      decoded.completeError(StateError('Invalid image'));
      await tester.pump();
      expect(controller.stage, MealPhotoStage.camera);
      expect(controller.photo, isNull);
      expect(controller.issue, MealPhotoIssue.capture);
      controller.dispose();
      await tester.pump();
    },
  );
}

class _Camera implements MealCamera {
  @override
  MealCameraFacing facing = MealCameraFacing.back;
  @override
  bool canSwitchFacing = true;
  Future<MealPhoto>? captureResult;
  Object? captureError;
  int captures = 0;
  int closes = 0;

  @override
  Future<MealPhoto> capture() {
    captures++;
    if (captureError != null) return Future.error(captureError!);
    return captureResult!;
  }

  @override
  Future<void> close() async => closes++;

  @override
  Widget preview() => const SizedBox.expand();
}

class _Repository implements MealPhotoRepository {
  @override
  bool get supportsRecovery => true;
  @override
  Future<MealCameraAccess> cameraAccess({bool request = false}) async =>
      MealCameraAccess.granted;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<MealPhoto?> pickPhoto() async => null;

  @override
  Future<MealPhoto?> recoverPickedPhoto() async => null;
}
