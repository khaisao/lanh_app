import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/meal_voice_recognizer.dart';

/// Asks for microphone and speech access on the screen that offers voice
/// logging, so the recording screen opens only once access is granted.
///
/// A refusal is explained in a dialog over the current screen, with a way
/// to Settings; a device without a recognizer gets a plain notice.
/// Returns true when the voice task may open.
Future<bool> ensureMealVoiceAccess(
  BuildContext context,
  MealVoiceRecognizer recognizer,
) async {
  MealVoiceAccess status;
  try {
    status = await recognizer.access(request: true);
  } catch (_) {
    status = MealVoiceAccess.unavailable;
  }
  if (status == MealVoiceAccess.granted) return true;
  if (!context.mounted) return false;
  await _showAccessNotice(context, recognizer, status);
  return false;
}

Future<void> _showAccessNotice(
  BuildContext context,
  MealVoiceRecognizer recognizer,
  MealVoiceAccess status,
) {
  final strings = AppLocalizations.of(context);
  final unavailable = status == MealVoiceAccess.unavailable;
  final buttonStyle = TextButton.styleFrom(
    minimumSize: const Size(0, AppSizes.action),
  );
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      key: const Key('meal-voice-access-dialog'),
      title: Text(strings.mealVoiceNoAccessTitle),
      content: Text(
        unavailable
            ? strings.mealVoiceDeviceUnavailable
            : strings.mealVoiceAccessDeniedBody,
      ),
      actions: [
        TextButton(
          key: const Key('meal-voice-access-close'),
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: buttonStyle,
          child: Text(strings.close),
        ),
        if (!unavailable)
          TextButton(
            key: const Key('meal-voice-access-settings'),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              var opened = false;
              try {
                opened = await recognizer.openSettings();
              } catch (_) {}
              if (!opened && context.mounted) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(strings.mealPhotoSettingsError)),
                );
              }
            },
            style: buttonStyle,
            child: Text(strings.mealPhotoOpenSettings),
          ),
      ],
    ),
  );
}
