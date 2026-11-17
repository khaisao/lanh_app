part of '../app_ui.dart';

/// The broccoli artwork and its 3.5 second bounce from the onboarding export.
class AppMascot extends StatefulWidget {
  const AppMascot({super.key, required this.size, this.bounce = false});

  final double size;
  final bool bounce;

  @override
  State<AppMascot> createState() => _AppMascotState();
}

class _AppMascotState extends State<AppMascot>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late final _position = _controller!.drive(
    TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -0.25),
          end: Offset.zero,
        ).chain(CurveTween(curve: const Cubic(0.8, 0, 1, 1))),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, -0.25),
        ).chain(CurveTween(curve: const Cubic(0, 0, 0.2, 1))),
        weight: 1,
      ),
    ]),
  );

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = widget.bounce && !MediaQuery.disableAnimationsOf(context);
    if (motion) {
      final controller = _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3500),
      );
      if (!controller.isAnimating) controller.repeat();
    } else {
      _controller?.reset();
    }

    final artwork = Image(
      image: const AssetImage('assets/design/images/welcome-broccoli.png'),
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    return ExcludeSemantics(
      child: motion
          ? SlideTransition(position: _position, child: artwork)
          : artwork,
    );
  }
}
