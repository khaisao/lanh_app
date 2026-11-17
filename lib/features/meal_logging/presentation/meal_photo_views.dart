part of 'meal_photo_flow.dart';

class _MealPhotoPermissionView extends StatelessWidget {
  const _MealPhotoPermissionView({
    required this.access,
    required this.busy,
    required this.requested,
    required this.onBack,
    required this.onChoose,
    required this.onRequest,
    required this.onSettings,
  });

  final MealCameraAccess? access;
  final bool busy;
  final bool requested;
  final VoidCallback onBack;
  final VoidCallback? onChoose;
  final VoidCallback onRequest;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final description = switch (access) {
      MealCameraAccess.blocked => strings.mealPhotoPermissionBlocked,
      MealCameraAccess.restricted => strings.mealPhotoPermissionRestricted,
      MealCameraAccess.unavailable => strings.mealPhotoCameraUnavailable,
      MealCameraAccess.denied when requested =>
        strings.mealPhotoPermissionDenied,
      _ => strings.mealPhotoPermissionBody,
    };
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppButton.surface(
                          onPressed: onBack,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: AppSpacing.xxs,
                            children: [
                              const AppIcon.asset(
                                'ph-caret-left-bold',
                                size: AppSizes.iconSm,
                                color: AppColors.primary,
                              ),
                              Flexible(
                                child: Text(
                                  strings.mealPhotoBack,
                                  style: AppTypography.button.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: AppSizes.photoPermissionBadge,
                              height: AppSizes.photoPermissionBadge,
                              decoration: BoxDecoration(
                                color: AppColors.card.withValues(alpha: 0.65),
                                border: Border.all(color: AppColors.card),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.xl,
                                ),
                              ),
                              child: const Center(
                                child: AppIcon.asset(
                                  'ph-camera-fill',
                                  size: AppSizes.photoPermissionIcon,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Semantics(
                              header: true,
                              child: Text(
                                strings.mealPhotoPermissionTitle,
                                style: AppTypography.screenTitle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSizes.readableWidth,
                              ),
                              child: Text(
                                description,
                                style: AppTypography.photoPermissionBody,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.sm,
                        children: [
                          if (access != MealCameraAccess.restricted)
                            AppButton(
                              onPressed: busy || access == null
                                  ? null
                                  : access == MealCameraAccess.blocked
                                  ? onSettings
                                  : onRequest,
                              child: Text(switch (access) {
                                MealCameraAccess.blocked =>
                                  strings.mealPhotoOpenSettings,
                                MealCameraAccess.unavailable => strings.retry,
                                _ => strings.mealPhotoAllowCamera,
                              }, textAlign: TextAlign.center),
                            ),
                          AppButton.surface(
                            onPressed: onChoose,
                            child: Text(
                              strings.mealPhotoChoose,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCameraView extends StatelessWidget {
  const _MealCameraView({
    required this.camera,
    required this.capturing,
    required this.loadingPhoto,
    required this.switchingCamera,
    required this.canSwitchCamera,
    required this.onClose,
    required this.onChoose,
    required this.onCapture,
    required this.onSwitchCamera,
  });

  final MealCamera? camera;
  final bool capturing;
  final bool loadingPhoto;
  final bool switchingCamera;
  final bool canSwitchCamera;
  final VoidCallback onClose;
  final VoidCallback? onChoose;
  final VoidCallback? onCapture;
  final VoidCallback? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppMediaOverlay(
      media:
          camera?.preview() ??
          Center(
            child: CircularProgressIndicator(
              color: AppColors.background,
              semanticsLabel: strings.mealPhotoCameraLoading,
              value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
            ),
          ),
      controls: _MediaControls(
        top: _MediaIconButton(
          icon: 'ph-x-bold',
          label: strings.close,
          visualSize: AppSizes.photoCloseControl,
          onPressed: onClose,
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (capturing || loadingPhoto || switchingCamera)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    capturing
                        ? strings.mealPhotoCapturing
                        : switchingCamera
                        ? strings.mealPhotoSwitching
                        : strings.mealPhotoLoading,
                    textAlign: TextAlign.center,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            Stack(
              alignment: Alignment.center,
              children: [
                if (canSwitchCamera)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _MediaIconButton(
                      icon: 'ph-camera-rotate',
                      label: strings.mealPhotoSwitchCamera,
                      visualSize: AppSizes.photoControl,
                      onPressed: onSwitchCamera,
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _MediaIconButton(
                    icon: 'ph-images-square',
                    label: strings.mealPhotoChoose,
                    visualSize: AppSizes.photoControl,
                    onPressed: onChoose,
                  ),
                ),
                IconButton(
                  tooltip: capturing
                      ? strings.mealPhotoCapturing
                      : strings.camera,
                  onPressed: onCapture,
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(AppSizes.photoShutter),
                    padding: const EdgeInsets.all(AppSpacing.stepGap),
                    side: const BorderSide(
                      color: AppColors.background,
                      width: AppSizes.photoShutterStroke,
                    ),
                  ),
                  icon: capturing
                      ? CircularProgressIndicator(
                          color: AppColors.background,
                          value: MediaQuery.disableAnimationsOf(context)
                              ? 1
                              : null,
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(
                              alpha: onCapture == null ? 0.5 : 1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.expand(),
                        ),
                ),
              ],
            ),
          ],
        ),
        bottomInset: AppSpacing.xxl,
      ),
    );
  }
}

class _MealPhotoReviewView extends StatelessWidget {
  const _MealPhotoReviewView({
    required this.photo,
    required this.captured,
    required this.loadingPhoto,
    required this.onBack,
    required this.onEstimate,
    required this.onReplace,
  });

  final MealPhoto photo;
  final bool captured;
  final bool loadingPhoto;
  final VoidCallback onBack;
  final VoidCallback onEstimate;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppMediaOverlay(
      media: Image(
        image: mealPhotoImage(photo),
        fit: BoxFit.cover,
        semanticLabel: strings.mealPhotoReviewLabel,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            strings.mealPhotoPickError,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.background),
          ),
        ),
      ),
      controls: _MediaControls(
        top: _MediaIconButton(
          icon: 'ph-caret-left-bold',
          label: strings.mealPhotoBack,
          visualSize: AppSizes.photoCloseControl,
          onPressed: onBack,
        ),
        bottom: AppMediaGlass(
          radius: AppRadii.xl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.xs,
              children: [
                if (loadingPhoto)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.mealPhotoLoading,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                AppButton(
                  onPressed: onEstimate,
                  child: Text(
                    strings.mealPhotoEstimate,
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: onReplace,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, AppSizes.action),
                    foregroundColor: AppColors.background,
                    textStyle: AppTypography.cardTitle,
                  ),
                  child: Text(
                    captured
                        ? strings.mealPhotoRetake
                        : strings.mealPhotoReplace,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomInset: AppSpacing.lg,
        horizontalInset: AppSpacing.sm,
      ),
    );
  }
}

class _MediaControls extends StatelessWidget {
  const _MediaControls({
    required this.top,
    required this.bottom,
    required this.bottomInset,
    this.horizontalInset = AppSpacing.pageHorizontal,
  });

  final Widget top;
  final Widget bottom;
  final double bottomInset;
  final double horizontalInset;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl,
                      AppSpacing.pageHorizontal,
                      AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: top,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalInset,
                      0,
                      horizontalInset,
                      bottomInset,
                    ),
                    child: bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MediaIconButton extends StatelessWidget {
  const _MediaIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.visualSize,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final double visualSize;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size.square(AppSizes.action),
      padding: EdgeInsets.zero,
      foregroundColor: AppColors.background,
    ),
    icon: AppMediaGlass(
      child: SizedBox.square(
        dimension: visualSize,
        child: Center(
          child: AppIcon.asset(
            icon,
            color: AppColors.background,
            size: AppSizes.iconMd,
          ),
        ),
      ),
    ),
  );
}
