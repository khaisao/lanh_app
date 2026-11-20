part of '../app_ui.dart';

/// Sweeps a soft light band across its child once, clipped to [radius].
/// The band waits for the first [delayFraction] of [duration] (so it plays
/// after an entrance settles), then crosses left to right. Reduce Motion
/// skips it. Used by the plan sheet's start action and the Home kcal meter.
class AppShineOnce extends StatefulWidget {
  const AppShineOnce({
    super.key,
    required this.child,
    this.duration = AppMotion.planShine,
    this.delayFraction = 0.6,
    this.radius = AppRadii.pill,
  });

  final Widget child;
  final Duration duration;
  final double delayFraction;
  final double radius;

  @override
  State<AppShineOnce> createState() => _AppShineOnceState();
}

class _AppShineOnceState extends State<AppShineOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && _controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final wait = widget.delayFraction;
                final t = ((_controller.value - wait) / (1 - wait)).clamp(
                  0.0,
                  1.0,
                );
                if (t == 0 || t == 1) return const SizedBox.shrink();
                return FractionalTranslation(
                  translation: Offset(-1 + 2 * t, 0),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0x40FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ],
  );
}
