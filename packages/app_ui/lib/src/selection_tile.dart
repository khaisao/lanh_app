part of '../app_ui.dart';

/// The single-choice tiles in the Profile Setup export.
class AppSelectionTile extends StatefulWidget {
  const AppSelectionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.compact = false,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool compact;

  @override
  State<AppSelectionTile> createState() => _AppSelectionTileState();
}

class _AppSelectionTileState extends State<AppSelectionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final selected = widget.selected;
    final duration = AppMotion.feedbackDuration(context);
    final border = selected ? AppBorders.selected : AppBorders.hairline;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedScale(
        scale: _pressed && duration != Duration.zero
            ? AppScales.pressedCard
            : 1,
        duration: duration,
        child: Material(
          color: AppColors.card,
          shape: AppSquircleBorder(
            radius: AppRadii.exportCardSquircle,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: duration == Duration.zero
                ? null
                : (pressed) => setState(() => _pressed = pressed),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact && selected
                    ? AppSpacing.sm + AppBorders.hairline + border
                    : AppSpacing.md + AppBorders.hairline,
                vertical: compact
                    ? AppSpacing.denseVertical +
                          AppBorders.hairline -
                          (selected ? AppBorders.selected : 0)
                    : AppSpacing.md + AppBorders.hairline,
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: SizedBox.square(
                      dimension: compact
                          ? AppSizes.avatar
                          : AppSizes.choiceIcon,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: AppSquircleBorder(
                            radius: compact
                                ? AppRadii.exportCompactSquircle
                                : AppRadii.exportCardSquircle,
                          ),
                          color: selected
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                        child: Center(
                          child: AppIcon.asset(
                            widget.icon,
                            size: compact ? AppSizes.iconMd : AppSizes.iconLg,
                            color: selected
                                ? AppColors.primaryForeground
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: compact && !selected
                          ? AppTypography.cardTitle.copyWith(
                              fontWeight: FontWeight.w500,
                            )
                          : AppTypography.cardTitle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: selected
                        ? const AppIcon.asset(
                            'ph-check-circle-fill',
                            color: AppColors.primary,
                          )
                        : Container(
                            width: AppSizes.iconLg,
                            height: AppSizes.iconLg,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  width: AppBorders.selected,
                                  color: AppColors.border,
                                ),
                              ),
                            ),
                          ),
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
