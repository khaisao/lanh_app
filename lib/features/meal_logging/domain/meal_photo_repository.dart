import 'dart:typed_data';

enum MealCameraAccess { granted, denied, blocked, restricted, unavailable }

class MealPhoto {
  const MealPhoto(this.bytes);

  final Uint8List bytes;
}

abstract interface class MealPhotoRepository {
  bool get supportsRecovery;
  Future<MealCameraAccess> cameraAccess({bool request = false});
  Future<bool> openSettings();
  Future<MealPhoto?> pickPhoto();
  Future<MealPhoto?> recoverPickedPhoto();
}
