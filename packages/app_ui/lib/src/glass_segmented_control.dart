part of '../app_ui.dart';

/// One option of an [AppGlassSegmentedControl]: its value, label and an
/// optional 16 px icon.
typedef AppSegment<T> = (T value, String label, String? icon);

/// A two-or-more option pill switch from the Profile Setup Target export:
/// a liquid glass track (`rounded-full p-1`) whose chosen segment is the
/// [AppChoice] selected state (`bg-secondary border-2 border-primary`, bold
/// text) and slides to the new value. Segments press to 0.97 with no ripple;
/// Reduce Motion makes both instant.
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
  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final index = segments.indexWhere((segment) => segment.$1 == selected);
    const gap = AppSpacing.xxs;
    return Semantics(
      label: label,
      explicitChildNodes: true,
      child: AppGlassCard(
        stadium: true,
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final count = segments.length;
            final width = (constraints.maxWidth - gap * (count - 1)) / count;
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
                    child: const DecoratedBox(
                      key: Key('app-segment-thumb'),
                      decoration: ShapeDecoration(
                        color: AppChoice.selectedFill,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: AppChoice.selectedStroke,
                            width: AppChoice.strokeWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  spacing: gap,
                  children: [
                    for (final (value, text, icon) in segments)
                      Expanded(
                        child: _Segment(
                          text: text,
                          icon: icon,
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
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.text,
    required this.icon,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final String text;
  final String? icon;
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
  Widget build(BuildContext context) {
    final color = widget.selected
        ? AppColors.foreground
        : AppColors.mutedForeground;
    return Semantics(
      checked: widget.selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: widget.text,
      excludeSemantics: true,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.stepGap,
                  children: [
                    if (widget.icon case final icon?)
                      AppIcon.asset(icon, size: AppSizes.iconXs, color: color),
                    Flexible(
                      child: AnimatedDefaultTextStyle(
                        duration: widget.reduceMotion
                            ? Duration.zero
                            : AppMotion.segmentSlide,
                        curve: AppMotion.segmentCurve,
                        style: AppTypography.choiceTitle.copyWith(
                          color: color,
                          fontWeight: widget.selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                        child: Text(widget.text, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
