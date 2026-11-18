import 'dart:async';

import 'package:lanh_app/features/meal_logging/domain/meal_voice_recognizer.dart';

/// Scripted recognizer: tests push events into the current session.
class TestMealVoiceRecognizer implements MealVoiceRecognizer {
  TestMealVoiceRecognizer({this.status = MealVoiceAccess.granted});

  MealVoiceAccess status;
  MealVoiceAccess? statusAfterRequest;
  final languages = <String>[];
  int stops = 0;
  int cancels = 0;
  int settingsOpened = 0;
  int requests = 0;
  bool openSettingsResult = true;
  StreamController<MealVoiceEvent>? _session;

  bool get listening => _session != null && !_session!.isClosed;

  @override
  Future<MealVoiceAccess> access({bool request = false}) async {
    if (request) requests++;
    if (request && statusAfterRequest != null) status = statusAfterRequest!;
    return status;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return openSettingsResult;
  }

  @override
  Stream<MealVoiceEvent> listen({required String languageCode}) {
    languages.add(languageCode);
    unawaited(_session?.close());
    final session = _session = StreamController<MealVoiceEvent>();
    return session.stream;
  }

  void hear(String text, {bool isFinal = false}) =>
      _session!.add(MealVoiceTranscript(text, isFinal: isFinal));

  void level(double value) => _session!.add(MealVoiceLevel(value));

  void fail(MealVoiceFailureKind kind) => _session!.add(MealVoiceFailure(kind));

  Future<void> finish() async => _session?.close();

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> cancel() async {
    cancels++;
    unawaited(_session?.close());
  }
}
