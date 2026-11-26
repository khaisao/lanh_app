import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Home weight row (Sleek "Hôm nay"): the latest weigh-in up to the day on
/// screen, without a date. [onUpdate] is null on past days, which are
/// read-only, so the action is hidden there.
class WeightCard extends StatelessWidget {
  const WeightCard({
    super.key,
    required this.kg,
    this.onUpdate,
    this.failed = false,
    this.onRetry,
  });

  /// Null when nothing was ever logged (or still loading).
  final double? kg;

  final VoidCallback? onUpdate;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPatternDigits(
      locale: strings.localeName,
      decimalDigits: 1,
    );
    final value = kg;
    return AppGlassCard(
      key: const Key('today-weight'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.card,
        vertical: AppSpacing.md,
      ),
      radius: AppRadii.glassInner,
      shadows: const [],
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          const AppGradientIconWell(
            icon: 'ph-scales',
            gradient: [AppColors.secondary, AppColors.card],
            color: AppColors.primary,
            size: AppSizes.iconTile,
            iconSize: AppSizes.iconSm,
          ),
          Expanded(
            // Value left, action right; the action drops below at large
            // text sizes instead of pushing the row over.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              children: [
                Semantics(
                  container: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.weightTitle, style: AppTypography.caption),
                      if (failed)
                        Text(
                          strings.weightReadError,
                          style: AppTypography.bodySmall,
                        )
                      else if (value == null)
                        Text(strings.weightNone, style: AppTypography.bodySmall)
                      else
                        Text(
                          strings.weightKg(format.format(value)),
                          key: const Key('today-weight-value'),
                          style: AppTypography.cardTitle,
                        ),
                    ],
                  ),
                ),
                if (failed && onRetry != null)
                  TextButton(onPressed: onRetry, child: Text(strings.retry))
                else if (onUpdate != null)
                  IconButton(
                    key: const Key('today-weight-update'),
                    tooltip: strings.weightUpdateTitle,
                    onPressed: onUpdate,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      fixedSize: const Size.square(AppSizes.compactAction),
                    ),
                    icon: const AppIcon.asset(
                      'ph-pencil-simple',
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
