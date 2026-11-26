import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'today_dashboard.dart';
import 'today_energy_card.dart';

/// Sleek Home 12: placeholders shaped like the kcal card while the profile
/// or today's meals are read from the device.
class TodayEnergySkeleton extends StatelessWidget {
  const TodayEnergySkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('today-energy-loading'),
    label: AppLocalizations.of(context).todayLoadingProfile,
    child: ExcludeSemantics(
      child: TodayCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        radius: AppRadii.glassInner,
        raised: true,
        child: _Pulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: const [
              Row(
                spacing: AppSpacing.sm,
                children: [
                  _Block(
                    width: AppSizes.energyIconWell,
                    height: AppSizes.energyIconWell,
                    radius: AppRadii.md,
                  ),
                  _Block(width: 96, height: AppSpacing.sm),
                ],
              ),
              _Block(width: 140, height: AppSpacing.xl),
              _Block(height: AppSizes.energyMeter),
              Row(
                spacing: AppSpacing.denseGap,
                children: [
                  _Block(
                    width: AppSizes.energyStatusIcon,
                    height: AppSizes.energyStatusIcon,
                    radius: AppRadii.pill,
                  ),
                  Expanded(child: _Block(height: AppSpacing.sm)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Sleek Home 12: two placeholder meal rows while the journal loads.
class TodayJournalSkeleton extends StatelessWidget {
  const TodayJournalSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    key: const Key('today-journal-loading'),
    child: TodayCard(
      child: _Pulse(
        child: Column(
          spacing: AppSpacing.md,
          children: [
            for (var row = 0; row < 2; row++)
              const Row(
                spacing: AppSpacing.sm,
                children: [
                  _Block(
                    width: AppSizes.choiceIcon,
                    height: AppSizes.choiceIcon,
                    radius: AppRadii.md,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xs,
                      children: [
                        _Block(width: 150, height: AppSpacing.sm),
                        _Block(width: 64, height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

/// Sleek Home 13: the profile could not be read; calm copy and a retry.
class TodayEnergyErrorCard extends StatelessWidget {
  const TodayEnergyErrorCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TodayCard(
      key: const Key('today-energy-error'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadii.glassInner,
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          TodayEnergyHeader(
            icon: 'ph-warning-circle-fill',
            label: strings.todayEnergy,
            warning: true,
          ),
          Text(strings.todayProfileReadError, style: AppTypography.bodySmall),
          AppButton.secondary(
            key: const Key('today-energy-retry'),
            onPressed: onRetry,
            leadingIcon: 'ph-arrow-clockwise-bold',
            label: strings.retry,
          ),
        ],
      ),
    );
  }
}

/// Sleek Home 13: today's meals could not be read; retry or log anyway.
class TodayJournalErrorCard extends StatelessWidget {
  const TodayJournalErrorCard({super.key, required this.onRetry, this.onLog});

  final VoidCallback onRetry;

  /// Null on past days, which are read-only.
  final VoidCallback? onLog;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TodayCard(
      key: const Key('today-journal-error'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Text(strings.todayMealReadError, style: AppTypography.bodySmall),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton.secondary(
                key: const Key('today-journal-retry'),
                onPressed: onRetry,
                leadingIcon: 'ph-arrow-clockwise-bold',
                label: strings.retry,
              ),
              if (onLog != null)
                AppButton(
                  onPressed: onLog,
                  leadingIcon: 'ph-plus-bold',
                  label: strings.logMeal,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadii.sm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.muted,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Gently breathes the placeholders; still under Reduce Motion.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
    lowerBound: .55,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _controller, child: widget.child);
}
