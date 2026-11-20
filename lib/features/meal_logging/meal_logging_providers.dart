import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/device_meal_camera.dart';
import 'data/device_meal_photo_repository.dart';
import 'data/device_meal_voice_recognizer.dart';
import 'data/fake_meal_analysis_repository.dart';
import 'data/http_meal_analysis_repository.dart';
import 'data/sqlite_meal_log_repository.dart';
import 'domain/meal_analysis.dart';
import 'domain/meal_log.dart';
import 'domain/meal_log_repository.dart';
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
const _useFakeMealAnalysis = bool.fromEnvironment(
  'LANH_USE_FAKE_MEAL_ANALYSIS',
  defaultValue: false,
);

Uri? mealApiBaseUri([String value = _mealApiBaseUrl]) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
}

final mealAnalysisRepositoryProvider = Provider<MealAnalysisRepository>(
  (ref) => _useFakeMealAnalysis
      ? FakeMealAnalysisRepository()
      : HttpMealAnalysisRepository(baseUri: mealApiBaseUri()),
);

final mealLogRepositoryProvider = Provider<MealLogRepository>(
  (ref) => SqliteMealLogRepository(),
);

final todayMealLogsProvider = FutureProvider<List<MealLog>>((ref) {
  return ref.watch(mealLogRepositoryProvider).readForDate(DateTime.now());
});

/// The meal the user saved most recently in this session, so Home can
/// confirm it and highlight its row once. Home clears it after showing.
final lastSavedMealProvider = NotifierProvider<LastSavedMeal, MealLog?>(
  LastSavedMeal.new,
);

class LastSavedMeal extends Notifier<MealLog?> {
  @override
  MealLog? build() => null;

  void record(MealLog meal) => state = meal;

  void clear() => state = null;
}

final mealVoiceRecognizerProvider = Provider<MealVoiceRecognizer>(
  (ref) => DeviceMealVoiceRecognizer(),
);
