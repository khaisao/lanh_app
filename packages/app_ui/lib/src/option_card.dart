part of '../app_ui.dart';

/// The icon, label and caret row in the goal and meal picker exports.
class AppOptionCard extends StatefulWidget {
  const AppOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onPressed,
    this.selected = false,
    this.caretSize = AppSizes.iconSm,
  });

  final String icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;
  final bool selected;
  final double caretSize;

  @override
  State<AppOptionCard> createState() => _AppOptionCardState();
}

class _AppOptionCardState extends State<AppOptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AppRadii.cardSquircle));
    final shape = RoundedSuperellipseBorder(
      borderRadius: radius,
      side: widget.selected
          ? const BorderSide(
              color: AppColors.primary,
              width: AppBorders.selected,
            )
          : const BorderSide(color: AppColors.border),
    );
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      selected: widget.selected,
      child: AnimatedScale(
        scale: _pressed ? AppScales.pressedCard : 1,
        duration: AppMotion.duration(context),
        child: Material(
          color: widget.selected ? AppColors.secondary : AppColors.card,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.md + AppBorders.hairline,
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: AppSizes.choiceIcon,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: widget.selected
                            ? AppColors.card
                            : AppColors.secondary,
                        shape: const RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.md),
                          ),
                        ),
                      ),
                      child: Center(
                        child: AppIcon.asset(
                          widget.icon,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTypography.cardTitle),
                        Text(
                          widget.description,
                          style: AppTypography.optionDescription,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  AppIcon.asset(
                    'ph-caret-right',
                    size: widget.caretSize,
                    color: AppColors.mutedForeground,
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
