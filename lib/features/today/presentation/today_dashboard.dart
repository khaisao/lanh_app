import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class TodayDashboard extends StatelessWidget {
  const TodayDashboard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.days,
    required this.energy,
    required this.water,
    required this.weight,
    required this.journal,
    this.onBackToToday,
  });

  /// "Hôm nay", or the date of the past day on screen.
  final String title;
  final String? subtitle;

  /// Shown on past days: the small text action back to today.
  final VoidCallback? onBackToToday;
  final Widget days;
  final Widget energy;
  final Widget water;
  final Widget weight;
  final Widget journal;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('today-screen'),
      body: AppPageList(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        key: const Key('today-title'),
                        style: AppTypography.screenTitle,
                      ),
                    ),
                    if (subtitle case final text?)
                      Text(text, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              if (onBackToToday != null)
                TextButton(
                  key: const Key('today-back-to-today'),
                  onPressed: onBackToToday,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(
                      AppSizes.compactAction,
                      AppSizes.compactAction,
                    ),
                  ),
                  child: Text(strings.today),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          days,
          const SizedBox(height: AppSpacing.md),
          energy,
          const SizedBox(height: AppSpacing.md),
          water,
          const SizedBox(height: AppSpacing.md),
          weight,
          const SizedBox(height: AppSpacing.xl),
          journal,
        ],
      ),
    );
  }
}

/// A past day without meals (Sleek "Hôm nay · Ngày trống"): no kcal meter,
/// since nothing was logged and missing data is not zero.
class TodayEmptyDayCard extends StatelessWidget {
  const TodayEmptyDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TodayCard(
      key: const Key('today-empty-day'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadii.glassCard,
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              const AppGradientIconWell(
                icon: 'ph-fire',
                gradient: [AppColors.energyTint, AppColors.card],
                color: AppColors.energy,
                size: AppSizes.iconTile,
                iconSize: AppSizes.iconSm,
              ),
              Text(strings.dayEnergy, style: AppTypography.label),
            ],
          ),
          Text(
            strings.dayNoMeals,
            style: AppTypography.title.copyWith(fontFamily: AppFonts.heading),
          ),
        ],
      ),
    );
  }
}

/// Journal placeholder for a past day with no meals.
class TodayNoMealsCard extends StatelessWidget {
  const TodayNoMealsCard({super.key});

  @override
  Widget build(BuildContext context) => TodayCard(
    key: const Key('today-no-meals'),
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      spacing: AppSpacing.xs,
      children: [
        const AppGradientIconWell(
          icon: 'game-icons-bowl-of-rice',
          gradient: [AppColors.secondary, AppColors.card],
          color: AppColors.primary,
          size: AppSizes.avatar,
          iconSize: AppSizes.iconSm,
        ),
        Text(
          AppLocalizations.of(context).dayNoMealsBody,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall,
        ),
      ],
    ),
  );
}

/// Today's liquid glass card, as in the Today export: `bg-card/70
/// backdrop-blur-xl border-card/80 ring-white/50`. Only the hero energy card
/// is [raised] with the glass drop shadow; the water and journal cards sit
/// flat (`rounded-2xl`, no shadow).
class TodayCard extends StatelessWidget {
  const TodayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.glassInner,
    this.raised = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool raised;

  @override
  Widget build(BuildContext context) => AppGlassCard(
    padding: padding,
    radius: radius,
    shadows: raised ? AppShadows.glassCard : const [],
    child: child,
  );
}

class TodayJournal extends StatelessWidget {
  const TodayJournal({super.key, required this.entries, this.onDetails});

  final List<Widget> entries;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(strings.todayJournal, style: AppTypography.sectionTitle),
            if (onDetails != null)
              TextButton(
                onPressed: onDetails,
                child: Text(strings.todayDetails),
              ),
          ],
        ),
        ...entries,
      ],
    );
  }
}

class TodayMealRow extends StatelessWidget {
  const TodayMealRow({
    super.key,
    required this.name,
    required this.time,
    required this.energy,
    this.photo,
    this.onTap,
    this.highlighted = false,
  });

  final String name;
  final String time;
  final String energy;
  final ImageProvider? photo;
  final VoidCallback? onTap;

  /// The meal was just saved: the row starts tinted and fades back once
  /// (Sleek Home 14). Reduce Motion skips the tint.
  final bool highlighted;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
    tween: ColorTween(
      begin: highlighted && !MediaQuery.disableAnimationsOf(context)
          ? AppColors.secondary
          : AppColors.secondary.withValues(alpha: 0),
      end: AppColors.secondary.withValues(alpha: 0),
    ),
    duration: AppMotion.todayHighlight,
    curve: Curves.easeInCubic,
    builder: (context, color, child) => ColoredBox(color: color!, child: child),
    child: _content(),
  );

  Widget _content() => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          SizedBox.square(
            dimension: AppSizes.choiceIcon,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: photo == null
                  ? const ColoredBox(
                      color: AppColors.secondary,
                      child: Center(
                        child: AppIcon.asset(
                          'game-icons-bowl-of-rice',
                          size: AppSizes.iconLg,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Image(
                      image: photo!,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.cardTitle),
                Text(time, style: AppTypography.caption),
              ],
            ),
          ),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                energy,
                textAlign: TextAlign.end,
                style: AppTypography.fieldLabel,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Empty-day journal card from the Today First Run export: the mascot, a
/// short invitation and one action into meal logging.
class TodayFirstMealCard extends StatelessWidget {
  const TodayFirstMealCard({super.key, required this.onLog});

  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TodayCard(
      key: const Key('today-first-meal'),
      radius: AppRadii.glassCard,
      raised: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          const AppEntrance(
            index: 0,
            child: AppMascot(size: AppSizes.planMascot - AppSpacing.lg),
          ),
          Text(
            strings.todayFirstMealTitle,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            strings.todayFirstMealBody,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: AppButton.card(
              key: const Key('today-first-meal-action'),
              fullWidth: true,
              onPressed: onLog,
              leadingIcon: 'ph-plus-bold',
              label: strings.logMeal,
            ),
          ),
        ],
      ),
    );
  }
}
