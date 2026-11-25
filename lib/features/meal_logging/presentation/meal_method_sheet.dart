import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../meal_logging_providers.dart';
import 'meal_photo_flow.dart';
import 'meal_voice_access_gate.dart';
import 'meal_voice_flow.dart';

enum _MealMethod { camera, voice }

/// Closes the picker, then opens the chosen task. Closing either task returns
/// to the tab that opened the picker, without showing the picker again.
Future<void> showMealMethodSheet(BuildContext context) async {
  final method = await _chooseMealMethod(context);
  if (!context.mounted) return;
  switch (method) {
    case _MealMethod.camera:
      await showMealPhotoFlow(context);
    case _MealMethod.voice:
      await showMealVoiceFlow(context);
    case null:
      return;
  }
}

Future<_MealMethod?> _chooseMealMethod(BuildContext context) {
  return showModalBottomSheet<_MealMethod>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    barrierColor: AppColors.modalBarrier,
    constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.duration(context),
      reverseDuration: AppMotion.duration(context),
    ),
    builder: (sheetContext) =>
        const SafeArea(top: false, child: _MealMethodSheetHost()),
  );
}

/// Keeps the picker open while voice access is requested, so the system
/// prompt appears over the screen that offered voice logging. The voice
/// task opens only after access is granted.
class _MealMethodSheetHost extends ConsumerStatefulWidget {
  const _MealMethodSheetHost();

  @override
  ConsumerState<_MealMethodSheetHost> createState() =>
      _MealMethodSheetHostState();
}

class _MealMethodSheetHostState extends ConsumerState<_MealMethodSheetHost> {
  bool _requestingVoice = false;

  void _pick(_MealMethod method) =>
      Navigator.of(context, rootNavigator: true).pop(method);

  Future<void> _voice() async {
    if (_requestingVoice) return;
    setState(() => _requestingVoice = true);
    final granted = await ensureMealVoiceAccess(
      context,
      ref.read(mealVoiceRecognizerProvider),
    );
    if (!mounted) return;
    setState(() => _requestingVoice = false);
    if (granted) _pick(_MealMethod.voice);
  }

  @override
  Widget build(BuildContext context) {
    return MealMethodSheet(
      onCamera: () => _pick(_MealMethod.camera),
      onVoice: _requestingVoice ? null : () => unawaited(_voice()),
    );
  }
}

class MealMethodSheet extends StatelessWidget {
  const MealMethodSheet({super.key, required this.onCamera, this.onVoice});

  final VoidCallback onCamera;

  /// Null while voice access is being requested.
  final VoidCallback? onVoice;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height * AppFractions.sheetMaxHeight,
      ),
      child: SingleChildScrollView(
        key: const Key('meal-method-sheet'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizes.avatar,
                height: AppSpacing.fieldGap,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          strings.chooseMealMethod,
                          style: AppTypography.title,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        strings.mealMethodSubtitle,
                        style: AppTypography.optionDescription,
                      ),
                    ],
                  ),
                ),
                AppNavigationButton.close(
                  key: const Key('close-meal-sheet'),
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppOptionCard(
              key: const Key('meal-method-camera'),
              primary: true,
              caretSize: AppSizes.iconMd,
              icon: 'ph-camera-fill',
              title: strings.camera,
              description: strings.mealPhotoDescription,
              onPressed: onCamera,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppOptionCard(
              key: const Key('meal-method-voice'),
              caretSize: AppSizes.iconMd,
              icon: 'ph-microphone',
              title: strings.mealVoice,
              description: strings.mealVoiceDescription,
              onPressed: onVoice,
            ),
          ],
        ),
      ),
    );
  }
}
