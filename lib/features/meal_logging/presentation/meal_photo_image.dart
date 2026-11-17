import 'package:material_ui/material_ui.dart';

import '../domain/meal_photo_repository.dart';

/// Bound decoded memory while keeping the original encoded photo in the flow.
ImageProvider mealPhotoImage(MealPhoto photo) =>
    ResizeImage(MemoryImage(photo.bytes), width: 2048);

Future<void> prepareMealPhoto(BuildContext context, MealPhoto photo) async {
  Object? failure;
  StackTrace? failureStack;
  await precacheImage(
    mealPhotoImage(photo),
    context,
    onError: (error, stackTrace) {
      failure = error;
      failureStack = stackTrace;
    },
  );
  if (failure != null) {
    Error.throwWithStackTrace(failure!, failureStack ?? StackTrace.current);
  }
}
