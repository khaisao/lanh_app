import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

/// One drawn tumbler on the Home water card. When [filled] flips it plays a
/// short pour (water rises with a rocking surface, the glass squashes and
/// springs back, droplets hop from the rim) or a drain (water falls and the
/// glass gives a small shake). The first build and Reduce Motion show the
/// end state at once.
class WaterGlass extends StatefulWidget {
  const WaterGlass({super.key, required this.filled, this.tappable = true});

  final bool filled;

  /// Draws the "+" hint in an empty glass; off when the day is read-only.
  final bool tappable;

  @override
  State<WaterGlass> createState() => _WaterGlassState();
}

class _WaterGlassState extends State<WaterGlass> with TickerProviderStateMixin {
  late final AnimationController _level = AnimationController(
    vsync: this,
    value: widget.filled ? 1 : 0,
  );
  late final AnimationController _motion = AnimationController(vsync: this);
  bool _pouring = true;

  // Squash, overshoot, settle: 1 → 0.9 → 1.12 → 0.97 → 1.
  static final _bounce = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: .9,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: .9,
        end: 1.12,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.12,
        end: .97,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: .97,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
  ]);

  @override
  void didUpdateWidget(WaterGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filled == widget.filled) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _level.value = widget.filled ? 1 : 0;
      _motion.value = 0;
      return;
    }
    _pouring = widget.filled;
    final duration = widget.filled ? AppMotion.waterPour : AppMotion.waterDrain;
    _level.animateTo(
      widget.filled ? 1 : 0,
      duration: duration,
      curve: widget.filled ? Curves.easeOutCubic : Curves.easeInCubic,
    );
    _motion
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _level.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_level, _motion]),
    builder: (context, _) {
      final t = _motion.value;
      final active = _motion.isAnimating;
      final scale = active && _pouring ? _bounce.transform(t) : 1.0;
      final angle = active && !_pouring
          ? .12 * math.sin(t * math.pi * 4) * (1 - t)
          : 0.0;
      return Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: CustomPaint(
            size: const Size(
              AppSizes.waterGlassWidth,
              AppSizes.waterGlassHeight,
            ),
            painter: _GlassPainter(
              level: _level.value,
              // The surface rocks while pouring, then rests as a soft wave.
              wavePhase: t * math.pi * 3,
              waveAmplitude: active ? 2.2 * (1 - t) + .6 : .6,
              droplets: active && _pouring ? t : null,
              tappable: widget.tappable,
            ),
          ),
        ),
      );
    },
  );
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.level,
    required this.wavePhase,
    required this.waveAmplitude,
    required this.droplets,
    required this.tappable,
  });

  final bool tappable;

  /// 0 empty … 1 full (water stands at 85 % of the glass when full).
  final double level;
  final double wavePhase;
  final double waveAmplitude;

  /// Pour progress for the rim droplets; null when none are shown.
  final double? droplets;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Tapered tumbler with a rounded base.
    final glass = Path()
      ..moveTo(w * .08, h * .03)
      ..lineTo(w * .92, h * .03)
      ..lineTo(w * .82, h * .9)
      ..quadraticBezierTo(w * .8, h * .97, w * .72, h * .97)
      ..lineTo(w * .28, h * .97)
      ..quadraticBezierTo(w * .2, h * .97, w * .18, h * .9)
      ..close();

    if (level > 0) {
      canvas.save();
      canvas.clipPath(glass);
      final top = h * .97 - (h * .85) * level;
      final water = Path()..moveTo(0, top);
      for (var x = 0.0; x <= w; x += 1) {
        water.lineTo(
          x,
          top + waveAmplitude * math.sin(wavePhase + x / w * math.pi * 2),
        );
      }
      water
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        water,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.waterLight, AppColors.waterDeep],
          ).createShader(Offset(0, top) & Size(w, h - top)),
      );
      if (level > .35) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .26, top + h * .12, 2, h * .32),
            const Radius.circular(1),
          ),
          Paint()..color = Colors.white.withValues(alpha: .7 * level),
        );
      }
      canvas.restore();
    }

    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = Color.lerp(AppColors.border, AppColors.waterDeep, level)!,
    );

    // A small "+" invites the tap while the glass is empty.
    if (tappable && level < .2) {
      final plus = Paint()
        ..color = AppColors.mutedForeground.withValues(alpha: 1 - level * 5)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      final c = Offset(w / 2, h * .55);
      canvas
        ..drawLine(c - const Offset(4, 0), c + const Offset(4, 0), plus)
        ..drawLine(c - const Offset(0, 4), c + const Offset(0, 4), plus);
    }

    // Three droplets hop out of the rim during the pour.
    final d = droplets;
    if (d != null && d > .15 && d < .8) {
      final p = (d - .15) / .65;
      final paint = Paint()
        ..color = AppColors.waterLight.withValues(alpha: 1 - p);
      for (final (dx, lift) in const [(-.32, 1.0), (0.0, 1.3), (.32, .9)]) {
        final x = w / 2 + dx * w * (.6 + p);
        final y = h * .03 - 10 * lift * math.sin(p * math.pi);
        canvas.drawCircle(Offset(x, y), 1.8 * (1 - p * .5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.level != level ||
      old.wavePhase != wavePhase ||
      old.waveAmplitude != waveAmplitude ||
      old.droplets != droplets ||
      old.tappable != tappable;
}
