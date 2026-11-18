import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/device_meal_camera.dart';
import 'data/device_meal_photo_repository.dart';
import 'data/device_meal_voice_recognizer.dart';
import 'data/http_meal_analysis_repository.dart';
import 'domain/meal_analysis.dart';
import 'domain/meal_photo_repository.dart';
import 'domain/meal_voice_recognizer.dart';
import 'presentation/meal_camera.dart';

final mealPhotoRepositoryProvider = Provider<MealPhotoRepository>(
  (ref) => DeviceMealPhotoRepository(),
);

final mealCameraFactoryProvider = Provider<MealCameraFactory>(
  (ref) => openDeviceMealCamera,
);

/// Base URL of the Lành meal API, for example `http://192.168.1.10:8080/`.
/// Set per build with `--dart-define=LANH_MEAL_API_BASE_URL=...`; never embed
/// the private inference server (Ollama) address here.
const _mealApiBaseUrl = String.fromEnvironment('LANH_MEAL_API_BASE_URL');

Uri? mealApiBaseUri([String value = _mealApiBaseUrl]) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
}

final mealAnalysisRepositoryProvider = Provider<MealAnalysisRepository>(
  (ref) => HttpMealAnalysisRepository(baseUri: mealApiBaseUri()),
);

final mealVoiceRecognizerProvider = Provider<MealVoiceRecognizer>(
  (ref) => DeviceMealVoiceRecognizer(),
);
