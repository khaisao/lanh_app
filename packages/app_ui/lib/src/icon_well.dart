part of '../app_ui.dart';

/// Sleek Menu icon well: a `rounded-2xl` squircle with a top-left → bottom-right
/// [gradient], a `white/60` edge and one centred icon. Used by the Menu rows
/// and the water reminder card.
class AppGradientIconWell extends StatelessWidget {
  const AppGradientIconWell({
    super.key,
    required this.icon,
    required this.gradient,
    this.color = AppColors.primary,
    this.size = AppMenu.well,
    this.iconSize = AppSizes.iconMd,
    this.edge = AppMenu.wellEdge,
    this.shadows,
  });

  final String icon;
  final List<Color> gradient;
  final Color color;
  final double size;
  final double iconSize;
  final Color edge;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shadows: shadows,
        shape: AppSquircleBorder(
          radius: AppRadii.glassInner,
          side: BorderSide(color: edge),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: AppIcon.asset(icon, size: iconSize, color: color),
    ),
  );
}
