part of 'meal_photo_flow.dart';

/// Unsaved estimate review, following the glass MealReview export. Only data
/// returned by the meal API is shown; unknown values stay unknown, never zero.
class _MealAnalysisResultView extends StatefulWidget {
  const _MealAnalysisResultView({
    required this.photo,
    required this.analysis,
    required this.portionScale,
    required this.onPortion,
    required this.onBack,
    required this.onDiscard,
  });

  /// Null when the estimate came from a voice or typed description.
  final MealPhoto? photo;
  final MealAnalysis analysis;
  final double portionScale;
  final ValueChanged<double> onPortion;
  final VoidCallback onBack;
  final VoidCallback onDiscard;

  @override
  State<_MealAnalysisResultView> createState() =>
      _MealAnalysisResultViewState();
}

class _MealAnalysisResultViewState extends State<_MealAnalysisResultView>
    with SingleTickerProviderStateMixin {
  // The export staggers lanh-enter..lanh-enter-4 and grows the macro bar.
  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _enter(int step, Widget child) {
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: Interval(step * 0.12, 0.55 + step * 0.12, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = _MealNumberFormat(strings);
    final analysis = widget.analysis;
    final scale = widget.portionScale;
    return _EstimationBackground(
      failed: false,
      child: BackdropGroup(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          bottomNavigationBar: _ResultDock(
            totalLabel: format.kcal(analysis.totalCalories(scale)),
            onDiscard: widget.onDiscard,
          ),
          body: Builder(
            builder: (context) => SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.contentMax,
                  ),
                  child: SingleChildScrollView(
                    key: const Key('meal-analysis-result'),
                    // extendBody reports the floating dock as bottom padding.
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.card,
                      AppSpacing.md,
                      AppSpacing.card,
                      MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _enter(
                          0,
                          _ResultHeader(
                            onBack: widget.onBack,
                            onClose: widget.onDiscard,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _enter(
                          1,
                          _ResultHero(photo: widget.photo, analysis: analysis),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _enter(
                          2,
                          _EnergyCard(
                            analysis: analysis,
                            scale: scale,
                            format: format,
                            onPortion: widget.onPortion,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _enter(
                          3,
                          _NutrientsCard(
                            analysis: analysis,
                            scale: scale,
                            format: format,
                            grow: CurvedAnimation(
                              parent: _entrance,
                              curve: const Interval(
                                0.4,
                                1,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _enter(
                          3,
                          _ItemsSection(
                            analysis: analysis,
                            scale: scale,
                            format: format,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.card),
                        _enter(
                          3,
                          _MascotNote(
                            text: [
                              if (analysis.itemsMissingCalories > 0)
                                strings.mealReviewMissingCalories(
                                  analysis.itemsMissingCalories,
                                ),
                              widget.photo == null
                                  ? strings.mealReviewTextDisclaimer
                                  : strings.mealReviewDisclaimer,
                            ].join(' '),
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.onBack, required this.onClose});

  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      children: [
        AppGlassIconButton(
          key: const Key('meal-analysis-back'),
          icon: 'ph-caret-left-bold',
          tooltip: strings.mealPhotoBack,
          onPressed: onBack,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              strings.mealReviewTitle,
              style: AppTypography.sectionTitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AppGlassIconButton(
          icon: 'ph-x-bold',
          tooltip: strings.mealReviewClose,
          color: AppColors.mutedForeground,
          iconSize: AppSizes.iconSm,
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.photo, required this.analysis});

  final MealPhoto? photo;
  final MealAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final names = analysis.items.map((item) => item.name).toList();
    final title = names.length == 1
        ? names.single
        : strings.mealReviewNameJoin(
            names.take(names.length - 1).join(', '),
            names.last,
          );
    const shape = AppSquircleBorder(radius: AppRadii.glassHero);
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: shape,
        shadows: AppShadows.mealReviewHero,
      ),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: shape),
        child: SizedBox(
          height: AppSizes.mealReviewHero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photo case final photo?)
                Semantics(
                  image: true,
                  label: strings.mealReviewPhotoLabel,
                  child: Image(
                    image: mealPhotoImage(photo),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                )
              else
                // A described meal has no photo: brand panel with the mascot.
                Semantics(
                  label: strings.mealReviewVoiceLabel,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.secondary, AppColors.chartBlue],
                      ),
                    ),
                    child: Align(
                      alignment: const Alignment(0.7, -0.35),
                      child: const AppMascot(size: AppSizes.voiceMascot),
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.foreground.withValues(alpha: 0.75),
                      AppColors.foreground.withValues(alpha: 0.1),
                      AppColors.foreground.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: AppGlassSurface(
                  stadium: true,
                  opacity: 0.55,
                  shadows: const [],
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.stepGap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.stepGap,
                    children: [
                      const AppIcon.asset(
                        'ph-stack-bold',
                        size: AppSizes.iconInfo,
                        color: AppColors.foreground,
                      ),
                      Text(
                        strings.mealReviewItemCount(names.length),
                        style: AppTypography.label.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Text(
                  title,
                  key: const Key('meal-analysis-name'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.background,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({
    required this.analysis,
    required this.scale,
    required this.format,
    required this.onPortion,
  });

  final MealAnalysis analysis;
  final double scale;
  final _MealNumberFormat format;
  final ValueChanged<double> onPortion;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final calories = analysis.totalCalories(scale);
    return AppGlassSurface(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.mealReviewEnergy,
                  style: AppTypography.label,
                ),
              ),
              const _EstimateBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            key: const Key('meal-analysis-total'),
            container: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: calories == null
                        ? strings.mealReviewUnknown
                        : format.calories(calories),
                  ),
                  if (calories != null)
                    TextSpan(
                      text: ' ${strings.mealReviewKcal}',
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              style: calories == null
                  ? AppTypography.numericLarge
                  : AppTypography.numericDisplay,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PortionSelector(
            analysis: analysis,
            selected: scale,
            format: format,
            onSelected: onPortion,
          ),
        ],
      ),
    );
  }
}

class _ResultDock extends StatelessWidget {
  const _ResultDock({required this.totalLabel, required this.onDiscard});

  final String totalLabel;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppGlassSurface(
              radius: AppRadii.glassHero,
              opacity: 0.7,
              shadows: AppShadows.glassDock,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.xxs,
                      AppSpacing.xs,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      spacing: AppSpacing.stepGap,
                      children: [
                        const AppIcon.asset(
                          'ph-plus-circle',
                          size: AppSizes.iconXs,
                          color: AppColors.mutedForeground,
                        ),
                        Expanded(
                          child: Text(
                            strings.mealReviewAddToday,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        Text(
                          totalLabel,
                          key: const Key('meal-analysis-dock-total'),
                          style: AppTypography.cardTitle.copyWith(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Saving needs the meal journal, which does not exist yet.
                  AppButton(
                    key: const Key('meal-analysis-save'),
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        const AppIcon.asset(
                          'ph-check-bold',
                          size: AppSizes.iconSm,
                          color: AppColors.secondaryForeground,
                        ),
                        Flexible(child: Text(strings.mealReviewSaveSoon)),
                      ],
                    ),
                  ),
                  TextButton(
                    key: const Key('meal-analysis-discard'),
                    onPressed: onDiscard,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppSizes.action),
                      foregroundColor: AppColors.mutedForeground,
                      textStyle: AppTypography.button,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(strings.mealReviewDiscard),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
