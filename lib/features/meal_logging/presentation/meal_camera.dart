import 'package:material_ui/material_ui.dart';

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
