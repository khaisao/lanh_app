part of '../app_ui.dart';

/// Rises and fades a child in once, after `index × AppMotion.entranceStagger`,
/// so a step's cards arrive one after another. One controller per child and
/// an [Interval] for the delay: no timers. Reduce Motion shows it at once.
class AppEntrance extends StatefulWidget {
  const AppEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = AppMotion.entranceStagger * widget.index;
    final total = AppMotion.entrance + delay;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (context, child) => Opacity(
      opacity: _progress.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _progress.value) * AppMotion.entranceRise),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

/// Text that rolls to a new value: the old value slides up and out while the
/// new one rises in. Used for numbers that change as the user picks options.
class AppRollingText extends StatelessWidget {
  const AppRollingText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppMotion.of(context, AppMotion.rollingText),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    layoutBuilder: (current, previous) => Stack(
      alignment: alignment,
      clipBehavior: Clip.none,
      children: [...previous, ?current],
    ),
    transitionBuilder: (child, animation) {
      final incoming = child.key == ValueKey(text);
      final offset = Tween(
        begin: Offset(0, incoming ? 0.45 : -0.45),
        end: Offset.zero,
      ).animate(animation);
      return ClipRect(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        ),
      );
    },
    child: Text(text, key: ValueKey(text), style: style, textAlign: textAlign),
  );
}

/// [AnimatedSize] that steps aside under Reduce Motion. A zero-duration
/// AnimatedSize restarts its controller inside layout, which Flutter rejects,
/// so the child is laid out directly instead.
class AppAnimatedSize extends StatelessWidget {
  const AppAnimatedSize({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: AppMotion.selection,
          curve: AppMotion.selectionCurve,
          alignment: alignment,
          child: child,
        );
}

/// A soft primary halo that swells out from behind [child] and fades, a few
/// times, when [active] turns true. Used to point at the log-meal action
/// while the day's journal is empty. Off under Reduce Motion.
class AppPulseHalo extends StatefulWidget {
  const AppPulseHalo({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<AppPulseHalo> createState() => _AppPulseHaloState();
}

class _AppPulseHaloState extends State<AppPulseHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
  );
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (--_remaining > 0) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 0;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(AppPulseHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _start();
    if (!widget.active) {
      _remaining = 0;
      _controller.value = 0;
    }
  }

  void _start() {
    if (MediaQuery.disableAnimationsOf(context) || _controller.isAnimating) {
      return;
    }
    _remaining = AppMotion.pulseCount;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_controller.value);
              if (_controller.value == 0) return const SizedBox.shrink();
              return Transform.scale(
                scale: 1 + 0.7 * t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.3 * (1 - t)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      widget.child,
    ],
  );
}
