/// Combined microphone and speech-recognition permission for voice logging.
enum MealVoiceAccess {
  granted,

  /// Not allowed yet, refused or blocked; Settings or typing remain.
  denied,

  /// The device has no usable speech recognizer.
  unavailable,
}

/// Why a listening session ended without a usable transcript.
enum MealVoiceFailureKind {
  /// The recognizer heard no words it could transcribe.
  noSpeech,

  /// The device has no recognizer for the app language.
  languageUnavailable,

  /// The platform recognizer failed (audio, network or service error).
  recognition,
}

/// One event from a listening session. A session's stream ends after the
/// recognizer finishes, whether it produced text, a failure or nothing.
sealed class MealVoiceEvent {
  const MealVoiceEvent();
}

/// The words recognized so far; [isFinal] marks the recognizer's last answer.
final class MealVoiceTranscript extends MealVoiceEvent {
  const MealVoiceTranscript(this.text, {this.isFinal = false});

  final String text;
  final bool isFinal;
}

/// Input loudness normalized to 0..1, for the listening animation only.
final class MealVoiceLevel extends MealVoiceEvent {
  MealVoiceLevel(double level) : level = level.isFinite ? level.clamp(0, 1) : 0;

  final double level;
}

final class MealVoiceFailure extends MealVoiceEvent {
  const MealVoiceFailure(this.kind);

  final MealVoiceFailureKind kind;
}

/// Device speech-to-text. Audio stays with the platform recognizer; only the
/// transcript the user confirms is sent for meal analysis.
abstract interface class MealVoiceRecognizer {
  /// Current access; with [request] the system prompt is shown when the
  /// platform still allows asking.
  Future<MealVoiceAccess> access({bool request = false});

  Future<bool> openSettings();

  /// Starts one session in [languageCode] (for example `vi`). Only one
  /// session runs at a time; starting another cancels the previous one.
  Stream<MealVoiceEvent> listen({required String languageCode});

  /// Stops listening and lets the recognizer deliver its final transcript.
  Future<void> stop();

  /// Stops listening and discards the session's transcript.
  Future<void> cancel();
}
