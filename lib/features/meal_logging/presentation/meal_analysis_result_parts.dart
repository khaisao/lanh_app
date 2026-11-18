part of 'meal_photo_flow.dart';

/// Locale-aware display rounding. Domain values keep full precision.
class _MealNumberFormat {
  _MealNumberFormat(this.strings)
    : _whole = NumberFormat.decimalPattern(strings.localeName)
        ..maximumFractionDigits = 0,
      _fraction = NumberFormat.decimalPattern(strings.localeName)
        ..maximumFractionDigits = 1;

  final AppLocalizations strings;
  final NumberFormat _whole;
  final NumberFormat _fraction;

  String calories(double value) => _whole.format(value);

  /// Small amounts keep one decimal so 0.4 g does not read as 0 g.
  String amount(double value) =>
      value < 10 ? _fraction.format(value) : _whole.format(value);

  String grams(double? value) => value == null
      ? strings.mealReviewUnknown
      : '${amount(value)} ${strings.mealUnitGram}';

  String portion(MealPortion portion, double scale) {
    final unit = switch (portion.unit) {
      MealPortionUnit.gram => strings.mealUnitGram,
      MealPortionUnit.milliliter => strings.mealUnitMilliliter,
      MealPortionUnit.serving => strings.mealUnitServing,
      MealPortionUnit.piece => strings.mealUnitPiece,
    };
    return '${amount(portion.amount * scale)} $unit';
  }

  String kcal(double? value) => value == null
      ? '${strings.mealReviewUnknown} ${strings.mealReviewKcal}'
      : '${calories(value)} ${strings.mealReviewKcal}';
}

/// Protein, carbohydrate and fat colors from the export's chart tokens.
enum _Macro {
  protein(AppColors.chartGold, 'ph-egg-fill'),
  carbs(AppColors.chartPeach, 'ph-grains-fill'),
  fat(AppColors.chartBlue, 'ph-drop-half-fill');

  const _Macro(this.color, this.icon);

  final Color color;
  final String icon;

  String label(AppLocalizations strings, {bool short = false}) =>
      switch (this) {
        _Macro.protein => strings.mealReviewProtein,
        _Macro.carbs => strings.mealReviewCarbs,
        _Macro.fat =>
          short ? strings.mealReviewFatShort : strings.mealReviewFat,
      };

  double? total(MealAnalysis analysis, double scale) => switch (this) {
    _Macro.protein => analysis.totalProtein(scale),
    _Macro.carbs => analysis.totalCarbohydrate(scale),
    _Macro.fat => analysis.totalFat(scale),
  };

  double? of(MealNutrition nutrition) => switch (this) {
    _Macro.protein => nutrition.proteinGrams,
    _Macro.carbs => nutrition.carbohydrateGrams,
    _Macro.fat => nutrition.fatGrams,
  };
}

class _EstimateBadge extends StatelessWidget {
  const _EstimateBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const ShapeDecoration(
      color: AppColors.accent,
      shape: StadiumBorder(),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.denseGap,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xxs,
        children: [
          const AppIcon.asset(
            'ph-sparkle-fill',
            size: AppSizes.iconBadge,
            color: AppColors.accentForeground,
          ),
          Text(
            AppLocalizations.of(context).mealReviewEstimateBadge,
            style: AppTypography.micro.copyWith(
              color: AppColors.accentForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PortionSelector extends StatelessWidget {
  const _PortionSelector({
    required this.analysis,
    required this.selected,
    required this.format,
    required this.onSelected,
  });

  final MealAnalysis analysis;
  final double selected;
  final _MealNumberFormat format;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final labels = {
      0.5: strings.mealReviewPortionHalf,
      1.0: strings.mealReviewPortionOne,
      1.5: strings.mealReviewPortionOneHalf,
    };
    return Semantics(
      label: strings.mealReviewPortionGroup,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: AppColors.background.withValues(alpha: 0.6),
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.glassRim),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.stepGap),
          child: Row(
            spacing: AppSpacing.stepGap,
            children: [
              for (final scale in mealPortionScales)
                Expanded(
                  child: _PortionOption(
                    key: Key('meal-portion-$scale'),
                    label: labels[scale]!,
                    calories: format.kcal(analysis.totalCalories(scale)),
                    selected: scale == selected,
                    onTap: () => onSelected(scale),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortionOption extends StatelessWidget {
  const _PortionOption({
    super.key,
    required this.label,
    required this.calories,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String calories;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    inMutuallyExclusiveGroup: true,
    checked: selected,
    button: true,
    child: AnimatedContainer(
      duration: AppMotion.dockSelectionDuration(context),
      curve: AppMotion.dockCurve,
      decoration: ShapeDecoration(
        color: selected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0),
        shape: const StadiumBorder(),
        shadows: selected ? AppShadows.primaryGlow : const [],
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.action),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.stepGap,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: selected
                          ? AppColors.primaryForeground
                          : AppColors.foreground,
                    ),
                  ),
                  Text(
                    calories,
                    textAlign: TextAlign.center,
                    style: AppTypography.micro.copyWith(
                      color: selected
                          ? AppColors.primaryForeground.withValues(alpha: 0.9)
                          : AppColors.mutedForeground,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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

class _NutrientsCard extends StatelessWidget {
  const _NutrientsCard({
    required this.analysis,
    required this.scale,
    required this.format,
    required this.grow,
  });

  final MealAnalysis analysis;
  final double scale;
  final _MealNumberFormat format;
  final Animation<double> grow;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final totals = {
      for (final macro in _Macro.values) macro: macro.total(analysis, scale),
    };
    final known = totals.values.whereType<double>().fold<double>(
      0,
      (a, b) => a + b,
    );
    return AppGlassSurface(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.mealReviewNutrients, style: AppTypography.label),
          if (known > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Semantics(
              image: true,
              label: strings.mealReviewNutrientsLabel(
                format.grams(totals[_Macro.protein]),
                format.grams(totals[_Macro.carbs]),
                format.grams(totals[_Macro.fat]),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: ColoredBox(
                  color: AppColors.muted,
                  child: SizedBox(
                    height: AppSizes.mealReviewMacroBar,
                    child: SizeTransition(
                      sizeFactor: grow,
                      axis: Axis.horizontal,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final macro in _Macro.values)
                            if ((totals[macro] ?? 0) > 0)
                              Expanded(
                                flex: (totals[macro]! / known * 1000).round(),
                                child: ColoredBox(color: macro.color),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.card),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.denseGap,
            children: [
              for (final macro in _Macro.values)
                Expanded(
                  child: _MacroTile(
                    macro: macro,
                    value: totals[macro],
                    format: format,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.macro,
    required this.value,
    required this.format,
  });

  final _Macro macro;
  final double? value;
  final _MealNumberFormat format;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final value = this.value;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: AppColors.background.withValues(alpha: 0.6),
          shape: const AppSquircleBorder(
            radius: AppRadii.glassPanel,
            side: BorderSide(color: AppColors.glassRim),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.denseVertical),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: AppSizes.avatar,
                  height: AppSizes.avatar,
                  decoration: BoxDecoration(
                    color: macro.color.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon.asset(
                    macro.icon,
                    size: AppSizes.iconMd,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xxs,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: value == null
                              ? strings.mealReviewUnknown
                              : format.amount(value),
                        ),
                        if (value != null)
                          TextSpan(
                            text: ' ${strings.mealUnitGram}',
                            style: AppTypography.label,
                          ),
                      ],
                    ),
                    style: value == null
                        ? AppTypography.cardTitle
                        : AppTypography.title.copyWith(
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                  ),
                  Text(macro.label(strings), style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({
    required this.analysis,
    required this.scale,
    required this.format,
  });

  final MealAnalysis analysis;
  final double scale;
  final _MealNumberFormat format;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    strings.mealReviewItemsTitle,
                    style: AppTypography.sectionTitle,
                  ),
                ),
              ),
              Text(
                strings.mealReviewItemCount(analysis.items.length),
                style: AppTypography.label,
              ),
            ],
          ),
        ),
        for (final item in analysis.items)
          _ItemCard(item: item, scale: scale, format: format),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.scale,
    required this.format,
  });

  final MealAnalysisItem item;
  final double scale;
  final _MealNumberFormat format;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final portion = item.portion;
    final calories = item.nutrition.caloriesKcal;
    // Drinks measured in millilitres use the export's cup icon.
    final icon = portion?.unit == MealPortionUnit.milliliter
        ? 'ph-coffee-bold'
        : 'ph-bowl-food';
    return Semantics(
      container: true,
      child: AppGlassSurface(
        radius: AppRadii.glassItem,
        shadows: AppShadows.glassItem,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Row(
              spacing: AppSpacing.sm,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: AppSizes.choiceIcon,
                    height: AppSizes.choiceIcon,
                    decoration: const ShapeDecoration(
                      color: AppColors.secondary,
                      shape: AppSquircleBorder(
                        radius: AppRadii.exportCardSquircle,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AppIcon.asset(
                      icon,
                      size: AppSizes.iconLg,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs / 2,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.button.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        [
                          if (portion != null) format.portion(portion, scale),
                          format.kcal(
                            calories == null ? null : calories * scale,
                          ),
                        ].join(' · '),
                        style: AppTypography.caption.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.stepGap,
              children: [
                for (final macro in _Macro.values)
                  _MacroChip(
                    color: macro.color,
                    text: strings.mealReviewMacroChip(
                      macro.label(strings, short: true),
                      format.grams(
                        macro.of(item.nutrition) == null
                            ? null
                            : macro.of(item.nutrition)! * scale,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: color.withValues(alpha: 0.25),
      shape: const StadiumBorder(),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.denseGap,
        vertical: AppSpacing.xxs,
      ),
      child: Text(
        text,
        style: AppTypography.micro.copyWith(
          color: AppColors.foreground,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ),
  );
}

class _MascotNote extends StatelessWidget {
  const _MascotNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: AppColors.muted.withValues(alpha: 0.6),
      shape: const StadiumBorder(side: BorderSide(color: AppColors.glassRim)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          const ExcludeSemantics(
            child: AppMascot(size: AppSizes.mealReviewMascot),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(height: 1.625),
            ),
          ),
        ],
      ),
    ),
  );
}
