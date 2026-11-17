import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/device_meal_photo_repository.dart';
import '../domain/meal_photo_repository.dart';

enum MealCameraFacing { back, front }

typedef MealCameraFactory = Future<MealCamera> Function(
  MealCameraFacing facing,
);

abstract interface class MealCamera {
  MealCameraFacing get facing;
  bool get canSwitchFacing;
  Widget preview();
  Future<MealPhoto> capture();
  Future<void> close();
}

Future<MealCamera> openDeviceMealCamera(MealCameraFacing facing) async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) throw StateError('No cameras available.');
  final direction = facing == MealCameraFacing.back
      ? CameraLensDirection.back
      : CameraLensDirection.front;
  final description =
      cameras
          .where((camera) => camera.lensDirection == direction)
          .firstOrNull ??
      cameras.first;
  final controller = CameraController(
    description,
    ResolutionPreset.high,
    enableAudio: false,
  );
  try {
    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    return _DeviceMealCamera(
      controller,
      canSwitchFacing:
          cameras.any(
            (camera) => camera.lensDirection == CameraLensDirection.back,
          ) &&
          cameras.any(
            (camera) => camera.lensDirection == CameraLensDirection.front,
          ),
    );
  } catch (_) {
    await controller.dispose();
    rethrow;
  }
}

class _DeviceMealCamera implements MealCamera {
  _DeviceMealCamera(this._controller, {required this.canSwitchFacing});

  final CameraController _controller;

  @override
  MealCameraFacing get facing =>
      _controller.description.lensDirection == CameraLensDirection.front
      ? MealCameraFacing.front
      : MealCameraFacing.back;

  @override
  final bool canSwitchFacing;

  @override
  Future<MealPhoto> capture() async {
    final file = await _controller.takePicture();
    return readTemporaryMealPhoto(file);
  }

  @override
  Future<void> close() async {
    await _controller.dispose();
  }

  @override
  Widget preview() => ValueListenableBuilder(
    valueListenable: _controller,
    builder: (context, value, child) {
      final orientation =
          value.lockedCaptureOrientation ?? value.deviceOrientation;
      final landscape =
          orientation == DeviceOrientation.landscapeLeft ||
          orientation == DeviceOrientation.landscapeRight;
      final ratio = landscape ? value.aspectRatio : 1 / value.aspectRatio;
      return LayoutBuilder(
        builder: (context, constraints) => ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: constraints.maxHeight * ratio,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        ),
      );
    },
    child: CameraPreview(_controller),
  );
}
