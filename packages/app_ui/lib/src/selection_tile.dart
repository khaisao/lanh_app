part of '../app_ui.dart';

/// The single-choice glass tiles in the Profile Setup export: `rounded-3xl`
/// liquid glass with an icon well, a label and a radio mark.
class AppSelectionTile extends StatelessWidget {
  const AppSelectionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.compact = false,
    this.description,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool compact;

  /// Optional second line, e.g. examples that explain the choice.
  final String? description;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: selected,
    inMutuallyExclusiveGroup: true,
    child: AppGlassCard(
      tone: selected ? AppGlassTone.selected : AppGlassTone.glass,
      onPressed: () {
        if (!selected) HapticFeedback.selectionClick();
        onPressed();
      },
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: compact ? AppChoice.wellCompact : AppChoice.well,
              // The icon well fills with primary as the tile is chosen.
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: selected ? 1 : 0),
                duration: AppMotion.of(context, AppMotion.selection),
                curve: AppMotion.selectionCurve,
                builder: (context, t, _) => DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: AppSquircleBorder(
                      radius: compact
                          ? AppRadii.exportCompactSquircle
                          : AppRadii.glassInner,
                    ),
                    color: Color.lerp(
                      AppChoice.wellIdle,
                      AppChoice.wellSelected,
                      t,
                    ),
                  ),
                  child: Center(
                    child: AppIcon.asset(
                      icon,
                      size: compact ? AppSizes.iconMd : AppSizes.iconLg,
                      color: Color.lerp(
                        AppChoice.iconIdle,
                        AppChoice.iconSelected,
                        t,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
          Expanded(
            child: description == null
                ? Text(label, style: AppTypography.cardTitle)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(label, style: AppTypography.cardTitle),
                      Text(description!, style: AppTypography.caption),
                    ],
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ExcludeSemantics(child: AppRadioMark(selected: selected)),
        ],
      ),
    ),
  );
}

/// The 24 dp radio mark: an empty `border-2 border-border` ring, or the
/// filled `ph:check-circle-fill` when selected.
class AppRadioMark extends StatelessWidget {
  const AppRadioMark({super.key, required this.selected, this.inverse = false});

  final bool selected;

  /// Light check on a primary card (`size-7 bg-primary-foreground`).
  final bool inverse;

  /// The check pops in with a slight overshoot; the empty ring fades back.
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppMotion.of(context, AppMotion.checkIn),
    switchInCurve: Curves.easeOutBack,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    ),
    child: KeyedSubtree(key: ValueKey(selected), child: _mark()),
  );

  Widget _mark() {
    if (inverse) {
      return SizedBox.square(
        dimension: AppSizes.iconXl,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: selected
                  ? BorderSide.none
                  : const BorderSide(
                      color: AppColors.border,
                      width: AppBorders.selected,
                    ),
            ),
            color: selected ? AppColors.primaryForeground : AppGlass.fill,
          ),
          child: selected
              ? const Center(
                  child: AppIcon.asset(
                    'ph-check-bold',
                    size: AppSizes.iconInfo,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
      );
    }
    return selected
        ? const AppIcon.asset(
            'ph-check-circle-fill',
            size: AppChoice.markSize,
            color: AppChoice.markSelected,
          )
        : const SizedBox.square(
            dimension: AppChoice.markSize,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    color: AppChoice.markIdle,
                    width: AppChoice.markStroke,
                  ),
                ),
              ),
            ),
          );
  }
}
