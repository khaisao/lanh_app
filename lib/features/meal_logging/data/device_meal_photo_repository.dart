import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/meal_photo_repository.dart';

class DeviceMealPhotoRepository implements MealPhotoRepository {
  DeviceMealPhotoRepository() {
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }
  }

  final _picker = ImagePicker();

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  bool get supportsRecovery => !kIsWeb && Platform.isAndroid;

  @override
  Future<MealCameraAccess> cameraAccess({bool request = false}) async {
    if (!_isMobile) return MealCameraAccess.unavailable;
    final result = request
        ? await Permission.camera.request()
        : await Permission.camera.status;
    return switch (result) {
      PermissionStatus.granted => MealCameraAccess.granted,
      PermissionStatus.permanentlyDenied => MealCameraAccess.blocked,
      PermissionStatus.restricted => MealCameraAccess.restricted,
      _ => MealCameraAccess.denied,
    };
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  @override
  Future<MealPhoto?> pickPhoto() async {
    if (!_isMobile) return null;
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    return file == null ? null : readTemporaryMealPhoto(file);
  }

  @override
  Future<MealPhoto?> recoverPickedPhoto() async {
    if (!supportsRecovery) return null;
    final result = await _picker.retrieveLostData();
    final files = result.files;
    if (files != null && files.isNotEmpty) {
      return readTemporaryMealPhoto(files.first);
    }
    final error = result.exception;
    if (error != null) throw error;
    return null;
  }
}

/// Both mobile plugins give the app a copy in its temporary directory.
Future<MealPhoto> readTemporaryMealPhoto(XFile file) async {
  try {
    return MealPhoto(await file.readAsBytes());
  } finally {
    try {
      await File(file.path).delete();
    } on FileSystemException {
      // The OS can also reclaim the temporary directory.
    }
  }
}
