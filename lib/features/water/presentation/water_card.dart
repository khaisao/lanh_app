import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/water_goal.dart';
import 'water_glass.dart';

/// Home water card (Sleek Home 01–15): one drawn glass per 250 ml of the
/// day's goal. Tapping any empty glass pours the next one; tapping any full
/// glass empties the last one, so the row always fills left to right and
/// each tap changes exactly one glass. Logging stops at the goal.
class WaterCard extends StatefulWidget {
  const WaterCard({
    super.key,
    required this.glasses,
    required this.goal,
    required this.failed,
    required this.onAdd,
    required this.onRemove,
    required this.onRetry,
    this.readOnly = false,
  });

  /// A past day: glasses show what was logged and do not respond to taps.
  final bool readOnly;

  /// Glasses logged today; null while loading.
  final int? glasses;

  /// Goal in glasses; null until the profile is read.
  final int? goal;
  final bool failed;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  State<WaterCard> createState() => _WaterCardState();
}

class _WaterCardState extends State<WaterCard> {
  @override
  void didUpdateWidget(WaterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final goal = widget.goal;
    final before = oldWidget.glasses;
    final now = widget.glasses;
    if (goal != null && before != null && now != null && before < goal) {
      if (now >= goal) HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(strings.localeName);
    final glasses = widget.glasses;
    final goal = widget.goal;
    final ready = glasses != null && goal != null && !widget.failed;
    final reached = ready && glasses >= goal;
    final amountStyle = AppTypography.fieldLabel.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return AppGlassCard(
      key: const Key('today-water'),
      padding: const EdgeInsets.all(AppSpacing.card),
      radius: AppRadii.glassInner,
      shadows: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: AppSpacing.xs,
            children: [
              const ExcludeSemantics(
                child: AppIcon.asset(
                  'ph-drop-fill',
                  size: AppSizes.iconSm,
                  color: AppColors.waterDeep,
                ),
              ),
              Expanded(
                // Label left, amount right; the amount drops below at large
                // text sizes instead of squeezing the label.
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      strings.todayWater,
                      style: AppTypography.fieldLabel.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (ready)
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          ExcludeSemantics(
                            child: Opacity(
                              opacity: 0,
                              child: Text(
                                strings.waterAmount(
                                  format.format(goal * waterGlassMilliliters),
                                  format.format(goal * waterGlassMilliliters),
                                ),
                                style: amountStyle,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: AppRollingText(
                              glasses == 0
                                  ? strings.todayNoWater
                                  : strings.waterAmount(
                                      format.format(
                                        glasses * waterGlassMilliliters,
                                      ),
                                      format.format(
                                        goal * waterGlassMilliliters,
                                      ),
                                    ),
                              key: const Key('today-water-amount'),
                              alignment: AlignmentDirectional.centerEnd,
                              style: amountStyle,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (widget.failed)
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.waterReadError,
                    style: AppTypography.bodySmall,
                  ),
                ),
                TextButton(
                  key: const Key('today-water-retry'),
                  onPressed: widget.onRetry,
                  child: Text(strings.retry),
                ),
              ],
            )
          else
            Row(
              children: [
                for (var index = 0; index < (goal ?? 0); index++)
                  Expanded(
                    child: _GlassButton(
                      index: index,
                      filled: glasses != null && index < glasses,
                      readOnly: widget.readOnly,
                      // Waits for today's count and the goal before logging.
                      onTap: !ready || widget.readOnly
                          ? null
                          : index < glasses
                          ? () {
                              HapticFeedback.selectionClick();
                              widget.onRemove();
                            }
                          : () {
                              HapticFeedback.lightImpact();
                              widget.onAdd();
                            },
                    ),
                  ),
              ],
            ),
          // Reduce Motion lays the child out directly: a zero-length
          // AnimatedSize trips a layout assertion when the goal is met.
          AppAnimatedSize(
            // Takes no space until the goal is met.
            child: reached
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      key: const Key('today-water-reached'),
                      spacing: AppSpacing.xs,
                      children: [
                        const ExcludeSemantics(
                          child: AppIcon.asset(
                            'ph-check-circle-fill',
                            size: AppSizes.iconXs,
                            color: AppColors.primary,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.readOnly
                                ? strings.waterReachedDay
                                : strings.waterReached,
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.index,
    required this.filled,
    required this.onTap,
    required this.readOnly,
  });

  final int index;
  final bool filled;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final number = '${index + 1}';
    return Semantics(
      key: Key('today-water-glass-$index'),
      button: !readOnly,
      enabled: onTap != null,
      label: filled
          ? strings.waterGlassFull(number)
          : strings.waterGlassEmpty(number),
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: AppSizes.waterGlassTarget / 2,
        child: SizedBox(
          height: AppSizes.waterGlassTarget,
          child: Center(
            child: WaterGlass(filled: filled, tappable: !readOnly),
          ),
        ),
      ),
    );
  }
}
