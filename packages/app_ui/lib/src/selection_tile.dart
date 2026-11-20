part of '../app_ui.dart';

/// The single-choice card shared by the Profile Setup Goal, Activity and
/// Target exports. Default: liquid glass with a secondary icon well and an
/// empty ring. Selected: solid secondary with the primary outline, a primary
/// well and a check circle ([AppChoice]).
///
/// [label] and [description] build the text column (`text-sm font-semibold`
/// over `text-xs text-muted-foreground`); [content] replaces it for richer
/// rows such as the target plan. Screen readers hear one checked radio named
/// [semanticLabel] (or the label and description).
class AppSelectionTile extends StatelessWidget {
  const AppSelectionTile({
    super.key,
    required this.icon,
    required String this.label,
    required this.selected,
    required this.onPressed,
    this.description,
    this.semanticLabel,
  }) : content = null;

  /// A choice card whose text column is [content].
  const AppSelectionTile.custom({
    super.key,
    required this.icon,
    required Widget this.content,
    required this.selected,
    required this.onPressed,
    required String this.semanticLabel,
  }) : label = null,
       description = null;

  final String icon;
  final String? label;

  /// Optional second line, e.g. examples that explain the choice.
  final String? description;
  final Widget? content;
  final bool selected;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final text =
        content ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.navLabelGap,
          children: [
            Text(label!, style: AppTypography.choiceTitle),
            if (description case final description?)
              Text(description, style: AppTypography.caption),
          ],
        );
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      excludeSemantics: true,
      label:
          semanticLabel ?? [label, description].whereType<String>().join(', '),
      child: AppGlassCard(
        tone: selected ? AppGlassTone.selected : AppGlassTone.glass,
        strokeWidth: AppChoice.strokeWidth,
        ripple: false,
        popOnSelect: false,
        onPressed: () {
          if (!selected) HapticFeedback.selectionClick();
          onPressed();
        },
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.denseVertical,
        ),
        child: Row(
          spacing: AppSpacing.sm,
          children: [
            AppIconWell(icon: icon, selected: selected),
            Expanded(child: text),
            AppRadioMark(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// The `size-10 rounded-2xl` icon well of a choice card: secondary with a
/// primary icon, cross-fading to primary with a light icon when [selected].
class AppIconWell extends StatelessWidget {
  const AppIconWell({super.key, required this.icon, this.selected = false});

  final String icon;
  final bool selected;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: AppChoice.well,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: AppMotion.of(context, AppMotion.selection),
        curve: AppMotion.selectionCurve,
        builder: (context, t, _) => DecoratedBox(
          decoration: ShapeDecoration(
            shape: const AppSquircleBorder(radius: AppRadii.glassInner),
            color: Color.lerp(AppChoice.wellIdle, AppChoice.wellSelected, t),
          ),
          child: Center(
            child: AppIcon.asset(
              icon,
              size: AppChoice.wellIcon,
              color: Color.lerp(AppChoice.iconIdle, AppChoice.iconSelected, t),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The 24 dp radio mark: an empty `border-2 border-border` ring, or a
/// `bg-primary` circle with a 12 px `ph:check-bold` when selected.
class AppRadioMark extends StatelessWidget {
  const AppRadioMark({super.key, required this.selected});

  final bool selected;

  /// The check pops in with a slight overshoot; the empty ring fades back.
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.checkIn),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: SizedBox.square(
        key: ValueKey(selected),
        dimension: AppChoice.markSize,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: selected ? AppChoice.markSelected : AppGlass.fill,
            shape: CircleBorder(
              side: selected
                  ? BorderSide.none
                  : const BorderSide(
                      color: AppChoice.markIdle,
                      width: AppChoice.strokeWidth,
                    ),
            ),
          ),
          child: selected
              ? const Center(
                  child: AppIcon.asset(
                    'ph-check-bold',
                    size: AppChoice.markCheck,
                    color: AppColors.primaryForeground,
                  ),
                )
              : null,
        ),
      ),
    ),
  );
}
