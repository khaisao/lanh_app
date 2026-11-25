part of 'meal_photo_flow.dart';

/// Estimating and Chưa ước lượng được for a photo, or for a description
/// when [photo] is null (voice or typed text).
class _MealPhotoEstimationView extends StatelessWidget {
  const _MealPhotoEstimationView({
    required this.photo,
    required this.failed,
    required this.failure,
    required this.onBack,
    required this.onRetry,
  });

  final MealPhoto? photo;
  final bool failed;
  final MealAnalysisFailureKind? failure;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _EstimationBackground(
      failed: failed,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                key: Key(failed ? 'meal-estimation-error' : 'meal-estimating'),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl - AppSpacing.stepGap,
                      AppSpacing.pageHorizontal,
                      AppSpacing.onboardingBottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                _EstimationBackButton(onPressed: onBack),
                                if (!failed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.denseVertical,
                                      vertical: AppSpacing.xs,
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: AppSizes.estimationNotice,
                                    ),
                                    decoration: const ShapeDecoration(
                                      color: AppColors.secondary,
                                      shape: StadiumBorder(),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: AppSpacing.stepGap,
                                      children: [
                                        const AppIcon.asset(
                                          'ph-info-bold',
                                          size: AppSizes.iconInfo,
                                          color: AppColors.primary,
                                        ),
                                        Flexible(
                                          child: Text(
                                            strings.mealEstimationNotice,
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(
                              height: AppSpacing.xl - AppSpacing.stepGap,
                            ),
                            Center(
                              child: _EstimationHero(
                                photo: photo,
                                failed: failed,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Semantics(
                              header: true,
                              liveRegion: true,
                              child: Text(
                                failed
                                    ? strings.mealEstimationErrorTitle
                                    : strings.mealEstimatingTitle,
                                style: AppTypography.setupHeading,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: failed ? AppSpacing.sm : AppSpacing.xs,
                            ),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: AppSizes.readableWidth,
                                ),
                                child: Text(
                                  failed
                                      ? _failureBody(
                                          strings,
                                          failure,
                                          text: photo == null,
                                        )
                                      : strings.mealEstimatingBody,
                                  style: AppTypography.estimationBody,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (!failed) ...[
                              const SizedBox(height: AppSpacing.xl),
                              _EstimationSteps(text: photo == null),
                            ],
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: failed
                              ? AppButton(
                                  onPressed: onRetry,
                                  fullWidth: true,
                                  leadingIcon: 'ph-arrow-clockwise-bold',
                                  label: strings.retry,
                                )
                              : AppButton.surface(
                                  onPressed: onBack,
                                  label: strings.mealEstimationCancel,
                                ),
                        ),
                      ],
                    ),
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

String _failureBody(
  AppLocalizations strings,
  MealAnalysisFailureKind? kind, {
  required bool text,
}) => text
    ? switch (kind) {
        MealAnalysisFailureKind.network =>
          strings.mealEstimationTextNetworkBody,
        MealAnalysisFailureKind.unavailable =>
          strings.mealEstimationTextUnavailableBody,
        MealAnalysisFailureKind.notConfigured =>
          strings.mealEstimationNotConfiguredBody,
        _ => strings.mealEstimationTextErrorBody,
      }
    : switch (kind) {
        MealAnalysisFailureKind.network => strings.mealEstimationNetworkBody,
        MealAnalysisFailureKind.unavailable =>
          strings.mealEstimationUnavailableBody,
        MealAnalysisFailureKind.invalidPhoto =>
          strings.mealEstimationInvalidPhotoBody,
        MealAnalysisFailureKind.notConfigured =>
          strings.mealEstimationNotConfiguredBody,
        MealAnalysisFailureKind.noFood ||
        MealAnalysisFailureKind.unexpected ||
        null => strings.mealEstimationErrorBody,
      };

class _EstimationBackground extends StatelessWidget {
  const _EstimationBackground({required this.failed, required this.child});

  final bool failed;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.background)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppSizes.estimationGradient,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary,
                  AppColors.chartBlue.withValues(alpha: 0.15),
                  AppColors.background.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -AppSpacing.xxl * 2,
          left: -AppSizes.summaryImage,
          child: _glow(AppColors.secondary),
        ),
        Positioned(
          top: AppSizes.readableWidth,
          right: -AppSpacing.xxl * 2,
          child: _glow(
            failed
                ? AppColors.chartGold.withValues(alpha: 0.2)
                : AppColors.chartBlue.withValues(alpha: 0.3),
          ),
        ),
        child,
      ],
    ),
  );

  Widget _glow(Color color) => ImageFiltered(
    imageFilter: ui.ImageFilter.blur(
      sigmaX: AppSizes.estimationBlur,
      sigmaY: AppSizes.estimationBlur,
    ),
    child: Container(
      width: AppSizes.welcomeOuterHalo,
      height: AppSizes.welcomeOuterHalo,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

class _EstimationHero extends StatefulWidget {
  const _EstimationHero({required this.photo, required this.failed});

  final MealPhoto? photo;
  final bool failed;

  @override
  State<_EstimationHero> createState() => _EstimationHeroState();
}

class _EstimationHeroState extends State<_EstimationHero>
    with SingleTickerProviderStateMixin {
  late final _rotation = AnimationController(
    vsync: this,
    duration: AppMotion.estimationOrbit,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(_EstimationHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMotion();
  }

  void _updateMotion() {
    if (widget.failed || MediaQuery.disableAnimationsOf(context)) {
      _rotation.reset();
    } else if (!_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: AppSizes.hero,
      child: widget.failed
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: _EstimationGlass(
                    radius: AppRadii.estimationHero,
                    shadows: AppShadows.estimationHero,
                    child: Center(
                      child: AppMascot(size: AppSizes.estimationErrorMascot),
                    ),
                  ),
                ),
                Positioned(
                  right: -AppSpacing.xs,
                  bottom: -AppSpacing.xs,
                  child: Container(
                    width: AppSizes.choiceIcon + AppSpacing.xs,
                    height: AppSizes.choiceIcon + AppSpacing.xs,
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: AppSpacing.xxs,
                      ),
                    ),
                    child: Center(
                      child: AppIcon.asset(
                        widget.photo == null
                            ? 'ph-microphone-slash'
                            : 'ph-eye-slash-bold',
                        size: AppSizes.estimationErrorIcon,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: RotationTransition(
                    key: const Key('meal-estimation-orbit'),
                    turns: _rotation,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          transform: const GradientRotation(-math.pi / 2),
                          colors: [
                            AppColors.primary.withValues(alpha: 0),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0),
                            AppColors.primary.withValues(alpha: 0),
                          ],
                          stops: const [0, 1 / 3, 260 / 360, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  left: AppSizes.estimationRingInset,
                  top: AppSizes.estimationRingInset,
                  right: AppSizes.estimationRingInset,
                  bottom: AppSizes.estimationRingInset,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned.fill(
                  left: AppSizes.estimationPhotoInset,
                  top: AppSizes.estimationPhotoInset,
                  right: AppSizes.estimationPhotoInset,
                  bottom: AppSizes.estimationPhotoInset,
                  child: ClipOval(
                    child: ColoredBox(
                      color: AppColors.card,
                      child: widget.photo == null
                          ? null
                          : Opacity(
                              opacity: 0.3,
                              child: Image(
                                image: mealPhotoImage(widget.photo!),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                const AppMascot(size: AppSizes.estimationMascot),
              ],
            ),
    ),
  );
}

class _EstimationSteps extends StatelessWidget {
  const _EstimationSteps({required this.text});

  final bool text;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _EstimationGlass(
      radius: AppRadii.estimationSteps,
      shadows: AppShadows.estimationSteps,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          spacing: AppSpacing.xxs,
          children: [
            for (final (index, label) in [
              text
                  ? strings.mealEstimationReceivedText
                  : strings.mealEstimationReceived,
              text
                  ? strings.mealEstimationRecognizingText
                  : strings.mealEstimationRecognizing,
              strings.mealEstimationPortion,
              strings.mealEstimationCalories,
            ].indexed)
              Semantics(
                container: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.denseVertical,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: ShapeDecoration(
                    color: index == 1
                        ? AppColors.secondary.withValues(alpha: 0.6)
                        : Colors.transparent,
                    shape: const AppSquircleBorder(radius: AppRadii.glassInner),
                  ),
                  child: Row(
                    spacing: AppSpacing.denseVertical,
                    children: [
                      ExcludeSemantics(
                        child: SizedBox.square(
                          dimension: AppSizes.estimationStepIcon,
                          child: index < 2
                              ? DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: index == 0
                                        ? const AppIcon.asset(
                                            'ph-check-bold',
                                            size: AppSizes.iconInfo,
                                            color: AppColors.primaryForeground,
                                          )
                                        : const _EstimationSpinner(),
                                  ),
                                )
                              : CustomPaint(painter: _WaitingStepPainter()),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.estimationStep.copyWith(
                            color: index > 1
                                ? AppColors.mutedForeground
                                : AppColors.foreground,
                            fontWeight: index == 1
                                ? FontWeight.w600
                                : index == 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSizes.estimationStatusMax,
                        ),
                        child: Text(
                          index == 0
                              ? strings.mealEstimationDone
                              : index == 1
                              ? strings.mealEstimationWorking
                              : strings.mealEstimationWaiting,
                          style: AppTypography.caption.copyWith(
                            color: index < 2
                                ? AppColors.primary
                                : AppColors.mutedForeground,
                            fontWeight: index < 2
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WaitingStepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - AppBorders.hairline) / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppBorders.hairline;
    const segments = 24;
    for (var index = 0; index < segments; index++) {
      canvas.drawArc(rect, index * 2 * math.pi / segments, 0.13, false, paint);
    }
  }

  @override
  bool shouldRepaint(_WaitingStepPainter oldDelegate) => false;
}

class _EstimationGlass extends StatelessWidget {
  const _EstimationGlass({
    required this.radius,
    required this.shadows,
    required this.child,
  });

  final double radius;
  final List<BoxShadow> shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = AppSquircleBorder(
      radius: radius,
      side: BorderSide(color: AppColors.card.withValues(alpha: 0.8)),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: AppSizes.estimationGlassBlur,
            sigmaY: AppSizes.estimationGlassBlur,
          ),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: AppColors.card.withValues(alpha: 0.75),
              shape: shape,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _EstimationBackButton extends StatelessWidget {
  const _EstimationBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppNavigationButton.back(
    onPressed: onPressed,
    tooltip: AppLocalizations.of(context).mealPhotoBack,
  );
}

class _EstimationSpinner extends StatefulWidget {
  const _EstimationSpinner();

  @override
  State<_EstimationSpinner> createState() => _EstimationSpinnerState();
}

class _EstimationSpinnerState extends State<_EstimationSpinner>
    with SingleTickerProviderStateMixin {
  late final _rotation = AnimationController(
    vsync: this,
    duration: AppMotion.estimationSpinner,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _rotation.reset();
    } else if (!_rotation.isAnimating) {
      _rotation.repeat();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    key: const Key('meal-estimation-spinner'),
    turns: _rotation,
    child: const AppIcon.asset(
      'ph-circle-notch-bold',
      size: AppSizes.iconXs,
      color: AppColors.primary,
    ),
  );
}
