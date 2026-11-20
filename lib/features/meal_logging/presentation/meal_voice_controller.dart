import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/meal_analysis.dart';
import '../domain/meal_voice_recognizer.dart';
import 'meal_photo_controller.dart' show mealPortionScales;

enum MealVoiceStage {
  /// Asking for microphone access; the system prompt may be showing.
  checking,

  /// Not recording: before access, after a refusal or after silence. The
  /// user can retry the microphone, open Settings, type instead or close.
  idle,
  listening,

  /// Stop was pressed; waiting for the recognizer's final transcript.
  finishing,

  /// The user reviews and edits the text before sending it.
  confirm,
  estimating,
  estimationError,
  result,
}

/// Owns one voice-logging task: permission, listening, transcript review and
/// the unsaved estimate. Audio never leaves the platform recognizer; only the
/// text confirmed on [MealVoiceStage.confirm] is sent for analysis.
class MealVoiceController extends ChangeNotifier {
  MealVoiceController(
    this._recognizer,
    this._analysis, {
    required this.languageCode,
  });

  final MealVoiceRecognizer _recognizer;
  final MealAnalysisRepository _analysis;
  final String languageCode;

  MealVoiceStage stage = MealVoiceStage.checking;
  MealVoiceAccess? access;
  bool busy = false;

  /// Words heard so far in the current session.
  String transcript = '';

  /// [transcript] as shown live: single spaces, no leading/trailing blanks.
  String get liveText => transcript
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .join(' ');

  /// Why the last session produced no text, shown on the idle screen.
  MealVoiceFailureKind? listenFailure;

  /// The editable description on the confirm screen.
  String draft = '';

  /// True when the draft was typed because voice was not used.
  bool typed = false;
  bool settingsFailed = false;

  MealAnalysis? analysis;
  MealAnalysisFailureKind? estimationFailure;
  double portionScale = 1;

  /// Input loudness 0..1. Separate from [notifyListeners] so only the
  /// waveform rebuilds on each audio buffer.
  final level = ValueNotifier<double>(0);
  Duration elapsed = Duration.zero;
  Timer? _ticker;

  StreamSubscription<MealVoiceEvent>? _session;
  int _sessionVersion = 0;
  MealVoiceFailureKind? _sessionFailure;
  int _estimationVersion = 0;
  Completer<void>? _estimationCancel;
  String? _requestId;
  String? _requestText;
  bool _disposed = false;
  bool _active = true;

  bool get canSend {
    final text = draft.trim();
    return text.isNotEmpty && text.length <= maxMealDescriptionLength;
  }

  int get wordCount =>
      draft.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  bool get hasAccess => access == MealVoiceAccess.granted;

  /// Opens the task on the recording screen: asks for access there (the
  /// system prompt appears over it) and listens as soon as it is allowed.
  Future<void> start() => _requestAndListen();

  /// The microphone button: listens, or asks again when access is missing.
  Future<void> record() => hasAccess ? startListening() : _requestAndListen();

  Future<void> _requestAndListen() async {
    if (_disposed || busy) return;
    busy = true;
    stage = MealVoiceStage.checking;
    _refresh();
    MealVoiceAccess status;
    try {
      status = await _recognizer.access(request: true);
    } catch (_) {
      status = MealVoiceAccess.unavailable;
    }
    if (_disposed) return;
    busy = false;
    access = status;
    stage = MealVoiceStage.idle;
    listenFailure = null;
    _refresh();
    if (status == MealVoiceAccess.granted) await startListening();
  }

  /// Re-reads access without prompting, for example after Settings, and
  /// starts listening when it was just granted.
  Future<void> refreshAccess() async {
    if (_disposed || busy || hasAccess || stage != MealVoiceStage.idle) return;
    MealVoiceAccess status;
    try {
      status = await _recognizer.access();
    } catch (_) {
      return;
    }
    if (_disposed || status != MealVoiceAccess.granted) return;
    access = status;
    _refresh();
    await startListening();
  }

  Future<void> openSettings() async {
    if (_disposed) return;
    settingsFailed = false;
    var opened = false;
    try {
      opened = await _recognizer.openSettings();
    } catch (_) {}
    if (_disposed) return;
    settingsFailed = !opened;
    _refresh();
  }

  Future<void> startListening() async {
    if (_disposed ||
        !_active ||
        busy ||
        access != MealVoiceAccess.granted ||
        (stage != MealVoiceStage.idle && stage != MealVoiceStage.confirm)) {
      return;
    }
    final version = ++_sessionVersion;
    await _session?.cancel();
    if (_disposed || version != _sessionVersion) return;
    transcript = '';
    listenFailure = null;
    _sessionFailure = null;
    level.value = 0;
    stage = MealVoiceStage.listening;
    _startClock();
    _refresh();
    _session = _recognizer
        .listen(languageCode: languageCode)
        .listen(
          (event) => _onEvent(version, event),
          onDone: () => _onSessionDone(version),
          onError: (Object _) {
            if (version == _sessionVersion) {
              _sessionFailure = MealVoiceFailureKind.recognition;
            }
          },
        );
  }

  void _onEvent(int version, MealVoiceEvent event) {
    if (_disposed || version != _sessionVersion) return;
    switch (event) {
      case MealVoiceTranscript(:final text, :final isFinal):
        if (text != transcript || isFinal) {
          transcript = text;
          _refresh();
        }
      case MealVoiceLevel(:final level):
        this.level.value = level;
      case MealVoiceFailure(:final kind):
        _sessionFailure = kind;
    }
  }

  void _onSessionDone(int version) {
    if (_disposed || version != _sessionVersion) return;
    _session = null;
    _stopClock();
    level.value = 0;
    final text = transcript.trim();
    if (text.isNotEmpty) {
      // Keep what was heard even if the recognizer reported a late error.
      draft = text.length > maxMealDescriptionLength
          ? text.substring(0, maxMealDescriptionLength)
          : text;
      typed = false;
      stage = MealVoiceStage.confirm;
    } else {
      listenFailure = _sessionFailure ?? MealVoiceFailureKind.noSpeech;
      stage = MealVoiceStage.idle;
    }
    _refresh();
  }

  /// Ends listening and keeps what was heard.
  Future<void> stopListening() async {
    if (_disposed || stage != MealVoiceStage.listening) return;
    stage = MealVoiceStage.finishing;
    _stopClock();
    _refresh();
    try {
      await _recognizer.stop();
    } catch (_) {
      _sessionFailure ??= MealVoiceFailureKind.recognition;
    }
  }

  /// Ends listening and discards the session, for close and cancel.
  Future<void> cancelListening() async {
    _sessionVersion++;
    final session = _session;
    _session = null;
    _stopClock();
    level.value = 0;
    if (session == null) return;
    // Release the microphone first; the old stream's events are ignored.
    unawaited(session.cancel());
    try {
      await _recognizer.cancel();
    } catch (_) {}
  }

  /// Uses the confirm screen as a text field instead of the microphone.
  void typeInstead() {
    if (_disposed || stage != MealVoiceStage.idle) return;
    typed = true;
    draft = '';
    stage = MealVoiceStage.confirm;
    _refresh();
  }

  void updateDraft(String value) {
    if (_disposed || stage != MealVoiceStage.confirm || value == draft) return;
    draft = value;
    _refresh();
  }

  /// Leaves the confirm screen for the microphone without recording yet.
  void returnToInput() {
    if (_disposed || stage != MealVoiceStage.confirm) return;
    transcript = '';
    listenFailure = null;
    stage = MealVoiceStage.idle;
    _refresh();
  }

  /// Discards the draft and records a new description.
  Future<void> recordAgain() async {
    if (_disposed || stage != MealVoiceStage.confirm) return;
    if (!hasAccess) {
      returnToInput();
      return _requestAndListen();
    }
    await startListening();
  }

  Future<void> startEstimation() async {
    if (_disposed ||
        !canSend ||
        (stage != MealVoiceStage.confirm &&
            stage != MealVoiceStage.estimationError)) {
      return;
    }
    final text = draft.trim();
    // The same text keeps one draft identity, so a retry is idempotent.
    if (_requestText != text) {
      _requestText = text;
      _requestId = _newRequestId();
    }
    final requestId = _requestId!;
    final version = ++_estimationVersion;
    final cancel = _estimationCancel = Completer<void>();
    stage = MealVoiceStage.estimating;
    estimationFailure = null;
    analysis = null;
    _refresh();
    MealAnalysis? result;
    MealAnalysisFailureKind? failure;
    try {
      result = await _analysis.analyzeText(
        text,
        requestId: requestId,
        cancel: cancel.future,
      );
    } on MealAnalysisFailure catch (error) {
      failure = error.kind;
    } catch (_) {
      failure = MealAnalysisFailureKind.unexpected;
    }
    if (_disposed || version != _estimationVersion) return;
    _estimationCancel = null;
    if (result != null) {
      analysis = result;
      portionScale = 1;
      stage = MealVoiceStage.result;
    } else {
      estimationFailure = failure;
      stage = MealVoiceStage.estimationError;
    }
    _refresh();
  }

  void selectPortion(double scale) {
    if (_disposed ||
        stage != MealVoiceStage.result ||
        !mealPortionScales.contains(scale) ||
        scale == portionScale) {
      return;
    }
    portionScale = scale;
    _refresh();
  }

  /// Leaves estimation or its unsaved result and returns to the same text.
  void returnToDraft() {
    if (_disposed ||
        (stage != MealVoiceStage.estimating &&
            stage != MealVoiceStage.estimationError &&
            stage != MealVoiceStage.result)) {
      return;
    }
    _cancelEstimation();
    analysis = null;
    estimationFailure = null;
    stage = MealVoiceStage.confirm;
    _refresh();
  }

  /// Leaving the foreground ends listening and keeps what was heard, since
  /// the platform interrupts the audio session anyway.
  void setActive(bool active) {
    _active = active;
    if (!active && stage == MealVoiceStage.listening) {
      unawaited(stopListening());
    }
  }

  void _startClock() {
    elapsed = Duration.zero;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsed = Duration(seconds: timer.tick);
      _refresh();
    });
  }

  void _stopClock() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _cancelEstimation() {
    _estimationVersion++;
    final cancel = _estimationCancel;
    _estimationCancel = null;
    if (cancel != null && !cancel.isCompleted) cancel.complete();
  }

  void _refresh() {
    if (!_disposed) notifyListeners();
  }

  static String _newRequestId() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  void dispose() {
    _cancelEstimation();
    unawaited(cancelListening());
    _disposed = true;
    level.dispose();
    super.dispose();
  }
}
