part of '../app_ui.dart';

/// The icon, label and caret row in the goal and meal picker exports.
class AppOptionCard extends StatelessWidget {
  const AppOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onPressed,
    this.selected = false,
    this.primary = false,
    this.caretSize = AppSizes.iconSm,
  });

  final String icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;
  final bool selected;
  final bool primary;
  final double caretSize;

  @override
  Widget build(BuildContext context) {
    final foreground = primary
        ? AppColors.primaryForeground
        : AppColors.foreground;
    final mutedForeground = primary
        ? AppColors.primaryForeground.withValues(alpha: 0.8)
        : AppColors.mutedForeground;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      selected: selected,
      child: AppGlassCard(
        tone: primary
            ? AppGlassTone.primary
            : selected
            ? AppGlassTone.selected
            : AppGlassTone.glass,
        onPressed: onPressed,
        padding: const EdgeInsets.all(AppSpacing.md + AppBorders.hairline),
        child: Row(
          children: [
            SizedBox.square(
              dimension: AppChoice.well,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: primary
                      ? AppColors.primaryForeground.withValues(alpha: 0.15)
                      : selected
                      ? AppChoice.wellSelected
                      : AppChoice.wellIdle,
                  shape: const AppSquircleBorder(radius: AppRadii.glassInner),
                ),
                child: Center(
                  child: AppIcon.asset(
                    icon,
                    color: primary
                        ? foreground
                        : selected
                        ? AppChoice.iconSelected
                        : AppChoice.iconIdle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(color: foreground),
                  ),
                  Text(
                    description,
                    style: AppTypography.optionDescription.copyWith(
                      color: mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AppIcon.asset(
              'ph-caret-right',
              size: caretSize,
              color: mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
