import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'meal_photo_flow.dart';

Future<void> showMealMethodSheet(BuildContext context) async {
  final shouldOpenCamera = await showModalBottomSheet<bool>(
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
    builder: (sheetContext) => SafeArea(
      top: false,
      child: MealMethodSheet(
        onCamera: () =>
            Navigator.of(sheetContext, rootNavigator: true).pop(true),
      ),
    ),
  );
  if (shouldOpenCamera == true && context.mounted) {
    await showMealPhotoFlow(context);
  }
}

class MealMethodSheet extends StatelessWidget {
  const MealMethodSheet({super.key, required this.onCamera});

  final VoidCallback onCamera;

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
                          style: AppTypography.pageHeading,
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
                IconButton(
                  key: const Key('close-meal-sheet'),
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    fixedSize: const Size.square(AppSizes.compactAction),
                  ),
                  icon: const AppIcon.asset(
                    'ph-x-bold',
                    color: AppColors.foreground,
                    size: AppSizes.iconSm,
                  ),
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
              caretSize: AppSizes.iconMd,
              icon: 'ph-microphone',
              title: strings.mealVoice,
              description: strings.mealVoiceDescription,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.mealMethodsNotice,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
