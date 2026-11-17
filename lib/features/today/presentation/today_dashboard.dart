import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class TodayDashboard extends StatelessWidget {
  const TodayDashboard({
    super.key,
    required this.energy,
    required this.water,
    required this.journal,
  });

  final Widget energy;
  final Widget water;
  final Widget journal;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('today-screen'),
    backgroundColor: AppColors.background,
    body: AppPageList(
      children: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).todayGreeting,
                style: AppTypography.screenTitle,
              ),
            ),
            const AppMascot(size: AppSizes.avatar),
            const CircleAvatar(
              radius: AppSizes.avatar / 2,
              backgroundColor: AppColors.secondary,
              child: AppIcon.asset('ph-user-circle', color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        energy,
        const SizedBox(height: AppSpacing.md),
        water,
        const SizedBox(height: AppSpacing.xl),
        journal,
      ],
    ),
  );
}

class TodayCard extends StatelessWidget {
  const TodayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.lg,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

class TodayEnergyCard extends StatelessWidget {
  const TodayEnergyCard({
    super.key,
    required this.mode,
    required this.heading,
    required this.value,
    required this.footer,
    this.progress,
    this.range,
    this.estimated = false,
    this.action,
  });

  final GoalType? mode;
  final String heading;
  final String value;
  final String footer;
  final double? progress;
  final (double, double)? range;
  final bool estimated;
  final Widget? action;

  @override
  Widget build(BuildContext context) => TodayCard(
    key: ValueKey('today-energy-${mode?.name ?? 'none'}'),
    padding: const EdgeInsets.all(AppSpacing.lg),
    radius: AppRadii.xl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(heading, style: AppTypography.label),
            if (estimated)
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    AppLocalizations.of(context).todayEstimated,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(value, style: AppTypography.numericLarge),
            Text(
              AppLocalizations.of(context).todayLoggedKcal,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        if (mode == GoalType.gain ||
            mode == GoalType.lose ||
            mode == GoalType.maintain)
          ExcludeSemantics(
            child: _EnergyTrack(mode: mode!, progress: progress, range: range),
          ),
        Text(footer, style: AppTypography.fieldLabel),
        ?action,
      ],
    ),
  );
}

class _EnergyTrack extends StatelessWidget {
  const _EnergyTrack({
    required this.mode,
    required this.progress,
    required this.range,
  });

  final GoalType mode;
  final double? progress;
  final (double, double)? range;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSizes.energyMarkerHeight,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = progress?.clamp(0.0, 1.0);
        final maintain = mode == GoalType.maintain;
        final band = range;
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            _bar(
              width,
              mode == GoalType.lose ? AppColors.secondary : AppColors.muted,
            ),
            if (maintain && band != null)
              Positioned(
                left: width * band.$1,
                child: Container(
                  width: width * (band.$2 - band.$1),
                  height: AppSizes.iconMd,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
            if (maintain && fraction != null)
              Positioned(
                left: (width - AppSizes.iconXs) * fraction,
                child: const SizedBox.square(
                  dimension: AppSizes.iconXs,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (!maintain && fraction != null) ...[
              _bar(width * fraction, AppColors.primary),
              Positioned(
                right: 0,
                child: Container(
                  width: AppBorders.selected,
                  height: AppSizes.energyMarkerHeight,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ],
        );
      },
    ),
  );

  Widget _bar(double width, Color color) => Container(
    width: width,
    height: AppSpacing.xs,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
  );
}

class TodayWaterCard extends StatelessWidget {
  const TodayWaterCard({super.key, required this.value, this.filled});

  final String value;
  final int? filled;

  @override
  Widget build(BuildContext context) => TodayCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs,
              children: [
                const AppIcon.asset('ph-drop-fill', color: AppColors.chartBlue),
                Text(
                  AppLocalizations.of(context).todayWater,
                  style: AppTypography.fieldLabel,
                ),
              ],
            ),
            Text(value, style: AppTypography.bodySmall),
          ],
        ),
        ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: AppSpacing.xs,
              children: [
                for (var index = 0; index < 6; index++)
                  SizedBox(
                    width: constraints.maxWidth / 6 - AppSpacing.xxs,
                    child: Center(
                      child: _WaterIndicator(
                        filled: filled != null && index < filled!,
                        hasReading: filled != null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _WaterIndicator extends StatelessWidget {
  const _WaterIndicator({required this.filled, required this.hasReading});

  final bool filled;
  final bool hasReading;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: AppSizes.waterIndicator,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.waterTint : AppColors.card,
        border: filled ? null : Border.all(color: AppColors.border),
      ),
      child: Center(
        child: AppIcon.asset(
          hasReading && !filled ? 'ph-plus-bold' : 'ph-drop-fill',
          color: filled ? AppColors.chartBlue : AppColors.mutedForeground,
          size: AppSizes.iconXs,
        ),
      ),
    ),
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
  });

  final String name;
  final String time;
  final String energy;
  final ImageProvider? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
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
