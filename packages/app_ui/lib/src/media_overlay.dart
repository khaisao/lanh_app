part of '../app_ui.dart';

/// Contrast above full-bleed photos or a camera feed.
class AppMediaOverlay extends StatelessWidget {
  const AppMediaOverlay({
    super.key,
    required this.media,
    required this.controls,
  });

  final Widget media;
  final Widget controls;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.foreground,
    child: Stack(
      fit: StackFit.expand,
      children: [
        media,
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.foreground.withValues(alpha: 0.5),
                  AppColors.foreground.withValues(alpha: 0),
                  AppColors.foreground.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),
        controls,
      ],
    ),
  );
}

/// Translucent surface for controls placed above media.
class AppMediaGlass extends StatelessWidget {
  const AppMediaGlass({
    super.key,
    required this.child,
    this.radius = AppRadii.pill,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: AppSpacing.sm,
          sigmaY: AppSpacing.sm,
        ),
        child: Material(
          color: AppColors.card.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: AppColors.background.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
