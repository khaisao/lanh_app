part of '../app_ui.dart';

/// A two-or-more option pill switch from the Profile Setup Target export:
/// a `bg-card/50 border-card/80 shadow-inner` track and a raised
/// `bg-card/90 shadow-md` thumb that slides to the selected value. Segments
/// press to 0.97 (`active:scale-[0.97]`) with no ripple or hover tint, as in
/// the export; Reduce Motion makes both instant.
class AppGlassSegmentedControl<T> extends StatelessWidget {
  const AppGlassSegmentedControl({
    super.key,
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// Accessible name of the group.
  final String label;
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final highContrast = MediaQuery.highContrastOf(context);
    final index = segments.indexWhere((segment) => segment.$1 == selected);
    const inset = AppSpacing.xxs;
    const gap = AppSpacing.xxs;
    return Semantics(
      label: label,
      explicitChildNodes: true,
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: StadiumBorder()),
        child: BackdropFilter(
          enabled: !highContrast,
          filter: ui.ImageFilter.blur(
            sigmaX: AppGlass.blurStrong,
            sigmaY: AppGlass.blurStrong,
          ),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: highContrast ? AppColors.muted : AppGlass.track,
              shape: const StadiumBorder(
                side: BorderSide(color: AppGlass.edge),
              ),
            ),
            position: DecorationPosition.background,
            child: DecoratedBox(
              // `shadow-inner`: a soft shade along the top inside edge.
              decoration: const ShapeDecoration(
                shape: StadiumBorder(),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [AppGlass.insetShade, Color(0x00000000)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(inset),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final count = segments.length;
                    final width =
                        (constraints.maxWidth - gap * (count - 1)) / count;
                    return Stack(
                      children: [
                        if (index >= 0)
                          AnimatedPositioned(
                            duration: reduceMotion
                                ? Duration.zero
                                : AppMotion.segmentSlide,
                            curve: AppMotion.segmentCurve,
                            top: 0,
                            bottom: 0,
                            left: index * (width + gap),
                            width: width,
                            child: DecoratedBox(
                              key: const Key('app-segment-thumb'),
                              decoration: ShapeDecoration(
                                color: highContrast
                                    ? AppColors.card
                                    : AppGlass.raised,
                                shape: StadiumBorder(
                                  side: highContrast
                                      ? const BorderSide(
                                          color: AppColors.primary,
                                        )
                                      : BorderSide.none,
                                ),
                                shadows: AppShadows.glassRaised,
                              ),
                            ),
                          ),
                        Row(
                          spacing: gap,
                          children: [
                            for (final (value, text) in segments)
                              Expanded(
                                child: _Segment(
                                  text: text,
                                  selected: value == selected,
                                  reduceMotion: reduceMotion,
                                  onTap: () {
                                    if (value == selected) return;
                                    HapticFeedback.selectionClick();
                                    onChanged(value);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.text,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _pressed = false;

  void _press(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    checked: widget.selected,
    inMutuallyExclusiveGroup: true,
    button: true,
    child: FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(true),
        onTapCancel: () => _press(false),
        onTapUp: (_) => _press(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed && !widget.reduceMotion ? AppScales.pressed : 1,
          duration: _pressed
              ? AppMotion.feedbackPress
              : AppMotion.feedbackRelease,
          curve: AppMotion.feedbackCurve,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.compactAction,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: widget.reduceMotion
                      ? Duration.zero
                      : AppMotion.segmentSlide,
                  curve: AppMotion.segmentCurve,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: widget.selected
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                  child: Text(widget.text, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
