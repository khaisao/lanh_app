part of '../app_ui.dart';

/// The slider thumb from the Profile Setup Target Custom export: a
/// `size-7 bg-card` disc with a `border-[3px] border-primary` ring and
/// `shadow-md`. Disabled sliders draw the ring in the border colour.
class AppSliderThumbShape extends SliderComponentShape {
  const AppSliderThumbShape();

  static const _radius = AppSizes.sliderThumb / 2;

  /// Material elevation close to `shadow-md`.
  static const _elevation = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: _radius));
    canvas.drawShadow(circle, AppColors.foreground, _elevation, true);
    canvas.drawCircle(center, _radius, Paint()..color = AppColors.card);
    canvas.drawCircle(
      center,
      _radius - AppBorders.thumbRing / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppBorders.thumbRing
        ..color =
            Color.lerp(
              AppColors.border,
              AppColors.primary,
              enableAnimation.value,
            ) ??
            AppColors.primary,
    );
  }
}
