import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/meal_voice_recognizer.dart';

/// Platform speech recognition: Speech framework on iOS, the system
/// SpeechRecognizer service on Android. Transcripts are never logged.
class DeviceMealVoiceRecognizer implements MealVoiceRecognizer {
  DeviceMealVoiceRecognizer({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  /// A session ends by itself after this much silence or total time.
  static const pauseFor = Duration(seconds: 6);
  static const listenFor = Duration(seconds: 60);

  /// Upper bound for the recognizer to deliver its final answer after stop.
  static const _finishGrace = Duration(seconds: 4);

  final SpeechToText _speech;
  bool _initialized = false;
  _Session? _session;

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// The plugin asks for permission natively (Speech + microphone on iOS,
  /// RECORD_AUDIO on Android), so the prompt does not depend on
  /// permission_handler's compile-time permission switches.
  @override
  Future<MealVoiceAccess> access({bool request = false}) async {
    if (!_isMobile) return MealVoiceAccess.unavailable;
    try {
      if (request) {
        if (await _ensureInitialized()) return MealVoiceAccess.granted;
        // Permission granted but no recognizer means the device lacks one.
        return await _speech.hasPermission
            ? MealVoiceAccess.unavailable
            : MealVoiceAccess.denied;
      }
      return await _speech.hasPermission
          ? MealVoiceAccess.granted
          : MealVoiceAccess.denied;
    } catch (_) {
      return MealVoiceAccess.unavailable;
    }
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    return _initialized = await _speech.initialize(
      onError: (error) => _session
        ?..fail(_failureFor(error))
        ..finish(),
      onStatus: (status) {
        if (status == SpeechToText.doneStatus) _session?.finish();
      },
    );
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  @override
  Stream<MealVoiceEvent> listen({required String languageCode}) {
    _session?.finish();
    final session = _session = _Session();
    unawaited(_start(session, languageCode));
    return session.events.stream;
  }

  Future<void> _start(_Session session, String languageCode) async {
    try {
      final ready = await _ensureInitialized();
      if (session.closed) return;
      if (!ready) {
        session
          ..fail(MealVoiceFailureKind.recognition)
          ..finish();
        return;
      }
      final localeId = await _localeFor(languageCode);
      if (session.closed) return;
      if (localeId == null) {
        session
          ..fail(MealVoiceFailureKind.languageUnavailable)
          ..finish();
        return;
      }
      await _speech.listen(
        onResult: (result) => _onResult(session, result),
        onSoundLevelChange: (level) =>
            session.add(MealVoiceLevel(_normalizedLevel(level))),
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: true,
          pauseFor: pauseFor,
          listenFor: listenFor,
        ),
      );
    } catch (_) {
      session
        ..fail(MealVoiceFailureKind.recognition)
        ..finish();
    }
  }

  void _onResult(_Session session, SpeechRecognitionResult result) {
    session.add(
      MealVoiceTranscript(result.recognizedWords, isFinal: result.finalResult),
    );
    if (result.finalResult) session.finish();
  }

  Future<String?> _localeFor(String languageCode) async {
    final locales = await _speech.locales();
    final language = languageCode.toLowerCase();
    String? match;
    for (final locale in locales) {
      final id = locale.localeId.replaceAll('-', '_');
      final parts = id.split('_');
      if (parts.first.toLowerCase() != language) continue;
      // Prefer the national variant, for example vi_VN over another region.
      if (parts.length > 1 && parts[1].toLowerCase() == language) {
        return locale.localeId;
      }
      match ??= locale.localeId;
    }
    return match;
  }

  /// iOS reports dBFS (about -60..0); Android reports RMS dB (about -2..10).
  double _normalizedLevel(double level) =>
      Platform.isIOS ? (level + 50) / 50 : (level + 2) / 12;

  MealVoiceFailureKind _failureFor(
    SpeechRecognitionError error,
  ) => switch (error.errorMsg) {
    'error_no_match' || 'error_speech_timeout' => MealVoiceFailureKind.noSpeech,
    'error_language_not_supported' ||
    'error_language_unavailable' ||
    'error_assets_not_installed' => MealVoiceFailureKind.languageUnavailable,
    _ => MealVoiceFailureKind.recognition,
  };

  @override
  Future<void> stop() async {
    final session = _session;
    if (session == null || session.closed) return;
    try {
      await _speech.stop();
    } catch (_) {
      return session.finish();
    }
    // Some recognizers never report done after stop; bound the wait.
    session.finishAfter(_finishGrace);
  }

  @override
  Future<void> cancel() async {
    final session = _session;
    _session = null;
    session?.finish();
    if (_initialized) await _speech.cancel();
  }
}

class _Session {
  final events = StreamController<MealVoiceEvent>();
  Timer? _fallback;

  bool get closed => events.isClosed;

  void add(MealVoiceEvent event) {
    if (!closed) events.add(event);
  }

  void fail(MealVoiceFailureKind kind) => add(MealVoiceFailure(kind));

  void finishAfter(Duration delay) {
    _fallback ??= Timer(delay, finish);
  }

  /// Closes the stream without waiting for a listener to drain it.
  void finish() {
    _fallback?.cancel();
    if (!closed) unawaited(events.close());
  }
}
