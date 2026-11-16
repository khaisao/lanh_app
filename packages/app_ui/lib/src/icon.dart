part of '../app_ui.dart';

/// An icon from the exported design asset set.
class AppIcon extends StatelessWidget {
  const AppIcon.asset(
    this.name, {
    super.key,
    this.size = AppSizes.iconLg,
    this.color,
    this.semanticsLabel,
  });

  final String name;
  final double size;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/design/icons/$name.svg',
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
    semanticsLabel: semanticsLabel,
  );
}
