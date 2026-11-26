part of '../app_ui.dart';

/// Visual states of [AppGlassCard].
enum AppGlassTone {
  /// Frosted glass, the default state of every card: translucent card fill,
  /// backdrop blur, `card/80` edge, white rim and a specular top highlight.
  glass,

  /// A chosen card ([AppChoice]): solid secondary fill, the 2 dp primary
  /// outline and a softer shadow.
  selected,

  /// Solid primary summary card with a primary glow.
  primary,
}

/// The liquid glass card every card in the app is built from.
///
/// It follows the [AppGlass] recipe: a translucent card fill over a shared
/// backdrop blur, a hairline `card/80` edge, an inner white ring and a
/// one-pixel specular highlight along the top edge. Wrap a scrolling page in a
/// [BackdropGroup] so sibling cards share one backdrop pass.
///
/// When [onPressed] is set the card scales down while pressed, unless the
/// platform asks to reduce motion. Tone changes cross-fade the fill, outline
/// and shadow; becoming chosen (from [AppGlassTone.glass]) also plays a small
/// pop when [popOnSelect] is true. [ripple] false drops the ink splash and
/// highlight for calm choice cards. High contrast replaces the glass with an
/// opaque card and a visible border.
class AppGlassCard extends StatefulWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.tone = AppGlassTone.glass,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.glassCard,
    this.stadium = false,
    this.onPressed,
    this.shadows,
    this.fill,
    this.blur = AppGlass.blur,
    this.pressedScale = AppScales.pressedCard,
    this.popOnSelect = true,
    this.ripple = true,
    this.strokeWidth = AppBorders.hairline,
  });

  final Widget child;
  final AppGlassTone tone;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool stadium;
  final VoidCallback? onPressed;

  /// Overrides the tone's default shadow.
  final List<BoxShadow>? shadows;

  /// Overrides the glass fill colour of the [AppGlassTone.glass] state.
  final Color? fill;
  final double blur;
  final double pressedScale;

  /// Plays the selection pop when the tone leaves [AppGlassTone.glass].
  final bool popOnSelect;

  /// Paints the Material ink splash and pressed highlight when tapped.
  final bool ripple;

  /// Width of the outline in the glass and selected states. Choice cards use
  /// [AppChoice.strokeWidth] in both so choosing never shifts the layout.
  final double strokeWidth;

  @override
  State<AppGlassCard> createState() => _AppGlassCardState();
}

class _AppGlassCardState extends State<AppGlassCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  // 1 → 1.03 → 1: a quick swell, then an overshooting settle.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: AppMotion.selectionPop,
  );
  late final Animation<double> _popScale = TweenSequence([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.03,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.03,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 65,
    ),
  ]).animate(_pop);

  @override
  void didUpdateWidget(AppGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.popOnSelect &&
        oldWidget.tone == AppGlassTone.glass &&
        widget.tone != AppGlassTone.glass &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.highContrastOf(context);
    final tone = widget.tone;
    final frosted = tone != AppGlassTone.primary && !highContrast;
    final side = switch (tone) {
      AppGlassTone.glass => BorderSide(
        color: highContrast ? AppColors.border : AppGlass.edge,
        width: widget.strokeWidth,
      ),
      AppGlassTone.selected => BorderSide(
        color: AppChoice.selectedStroke,
        width: widget.strokeWidth,
      ),
      AppGlassTone.primary => BorderSide.none,
    };
    final shape = _shape(side);
    final fill = switch (tone) {
      AppGlassTone.primary => AppColors.primary,
      AppGlassTone.selected => AppChoice.selectedFill,
      _ when highContrast => AppGlass.contrastFill,
      _ => widget.fill ?? AppGlass.fill,
    };
    final shadows =
        widget.shadows ??
        switch (tone) {
          AppGlassTone.primary => AppShadows.primaryCard,
          AppGlassTone.selected => AppChoice.selectedShadow,
          AppGlassTone.glass => AppShadows.glassCard,
        };

    final onPressed = widget.onPressed;
    final duration = AppMotion.feedbackDuration(context);
    final toneDuration = AppMotion.of(context, AppMotion.selection);
    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (onPressed != null) {
      // Ink paints on this transparent Material: above the fill, below the
      // content, so text fields inside a card keep their own gestures.
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          splashFactory: widget.ripple ? null : NoSplash.splashFactory,
          highlightColor: widget.ripple ? null : const Color(0x00FFFFFF),
          onHighlightChanged: duration == Duration.zero
              ? null
              : (value) => setState(() => _pressed = value),
          child: content,
        ),
      );
    }
    // The tree keeps the same shape for every tone (the blur is toggled,
    // not removed) so fill, outline and shadow can animate between tones.
    Widget surface = AnimatedContainer(
      duration: toneDuration,
      curve: AppMotion.selectionCurve,
      decoration: tone == AppGlassTone.primary && !highContrast
          ? ShapeDecoration(gradient: AppGradients.action, shape: shape)
          : ShapeDecoration(color: fill, shape: shape),
      child: content,
    );
    surface = CustomPaint(
      foregroundPainter: frosted
          ? _GlassSheenPainter(
              shape: _shape(BorderSide.none),
              inset: side.width,
            )
          : null,
      child: surface,
    );
    final filter = ui.ImageFilter.blur(
      sigmaX: widget.blur,
      sigmaY: widget.blur,
    );
    surface = BackdropGroup.of(context) == null
        ? BackdropFilter(filter: filter, enabled: frosted, child: surface)
        : BackdropFilter.grouped(
            filter: filter,
            enabled: frosted,
            child: surface,
          );
    surface = AnimatedContainer(
      duration: toneDuration,
      curve: AppMotion.selectionCurve,
      // Shadow only: the outline is painted once, by the fill layer above.
      // Painting it here too doubled the stroke under translucent fills.
      decoration: ShapeDecoration(
        shape: _shape(BorderSide.none),
        shadows: shadows,
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: surface,
      ),
    );
    surface = ScaleTransition(scale: _popScale, child: surface);
    if (onPressed == null) return surface;
    return AnimatedScale(
      scale: _pressed && duration != Duration.zero ? widget.pressedScale : 1,
      duration: duration,
      curve: AppMotion.feedbackCurve,
      child: surface,
    );
  }

  OutlinedBorder _shape(BorderSide side) => widget.stadium
      ? StadiumBorder(side: side)
      : AppSquircleBorder(radius: widget.radius, side: side);
}

/// Paints the inner white ring and the specular top highlight of the glass.
class _GlassSheenPainter extends CustomPainter {
  const _GlassSheenPainter({required this.shape, required this.inset});

  final OutlinedBorder shape;

  /// Width of the card's outline; the white ring sits just inside it, as
  /// `ring-inset` does inside a CSS border, instead of covering it.
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inner = shape.getOuterPath(
      rect.deflate(inset + AppBorders.hairline / 2),
    );
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppBorders.hairline
        ..color = AppGlass.ring,
    );
    final highlightDepth = size.height.clamp(1.0, AppSpacing.lg);
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppBorders.hairline * 1.5
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, highlightDepth),
          const [AppGlass.highlight, Color(0x00FFFFFF)],
        ),
    );
  }

  @override
  bool shouldRepaint(_GlassSheenPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.inset != inset;
}
