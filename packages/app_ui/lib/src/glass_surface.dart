part of '../app_ui.dart';

/// Frosted surface from the MealReview export: `bg-card/60 backdrop-blur-2xl
/// border-white/60`. It is the [AppGlassCard] recipe with the MealReview fill
/// and blur, so the specular rim and high-contrast fallback stay shared.
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    super.key,
    required this.child,
    this.radius = AppRadii.glassPanel,
    this.shadows = AppShadows.glassPanel,
    this.opacity = 0.6,
    this.padding = EdgeInsets.zero,
    this.stadium = false,
  });

  final Widget child;
  final double radius;
  final List<BoxShadow> shadows;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final bool stadium;

  @override
  Widget build(BuildContext context) => AppGlassCard(
    radius: radius,
    stadium: stadium,
    shadows: shadows,
    padding: padding,
    fill: AppColors.card.withValues(alpha: opacity),
    blur: AppSizes.glassBlur,
    child: child,
  );
}

/// Round frosted icon control from the MealReview header (`size-11`), kept
/// inside a 56 dp touch target.
class AppGlassIconButton extends StatelessWidget {
  const AppGlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.primary,
    this.iconSize = AppSizes.iconMd,
  });

  final String icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final double iconSize;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    excludeFromSemantics: true,
    child: Semantics(
      button: true,
      label: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: AppSizes.action / 2,
        child: SizedBox.square(
          dimension: AppSizes.action,
          child: Center(
            child: AppGlassSurface(
              stadium: true,
              shadows: AppShadows.glassControl,
              child: SizedBox.square(
                dimension: AppSizes.glassControl,
                child: Center(
                  child: AppIcon.asset(icon, size: iconSize, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
