part of '../app_ui.dart';

/// Frosted card from the MealReview export: `bg-card/60 backdrop-blur-2xl
/// border-white/60` with a soft drop shadow.
///
/// Inside a [BackdropGroup] the blur is shared with sibling surfaces, so a
/// scrolling page with many cards renders one backdrop pass.
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
  Widget build(BuildContext context) {
    const side = BorderSide(color: AppColors.glassEdge);
    final ShapeBorder shape = stadium
        ? const StadiumBorder(side: side)
        : AppSquircleBorder(radius: radius, side: side);
    final filter = ui.ImageFilter.blur(
      sigmaX: AppSizes.glassBlur,
      sigmaY: AppSizes.glassBlur,
    );
    final content = DecoratedBox(
      decoration: ShapeDecoration(
        color: AppColors.card.withValues(alpha: opacity),
        shape: shape,
      ),
      child: Padding(padding: padding, child: child),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, shadows: shadows),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropGroup.of(context) == null
            ? BackdropFilter(filter: filter, child: content)
            : BackdropFilter.grouped(filter: filter, child: content),
      ),
    );
  }
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
