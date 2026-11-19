import 'dart:async';
import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/body_metrics.dart';
import '../domain/profile.dart';
import '../domain/teen_bmi.dart';

/// Inputs behind one BMI reading; equal inputs mean an equal reading.
@immutable
final class ProfileBmiInput {
  const ProfileBmiInput({
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    required this.sex,
  });

  final int ageYears;
  final double heightCm;
  final double weightKg;
  final ProfileSex sex;

  /// Complete, plausible inputs, or null while anything is missing or out of
  /// range. Missing data never produces a partial reading.
  static ProfileBmiInput? from({
    required int? ageYears,
    required double? heightCm,
    required double? weightKg,
    required ProfileSex? sex,
  }) {
    if (ageYears == null ||
        heightCm == null ||
        weightKg == null ||
        sex == null ||
        ageYears < BodyLimits.minAge ||
        ageYears > BodyLimits.maxAge ||
        heightCm < BodyLimits.minHeightCm ||
        heightCm > BodyLimits.maxHeightCm ||
        weightKg < BodyLimits.minWeightKg ||
        weightKg > BodyLimits.maxWeightKg) {
      return null;
    }
    return ProfileBmiInput(
      ageYears: ageYears,
      heightCm: heightCm,
      weightKg: weightKg,
      sex: sex,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProfileBmiInput &&
      other.ageYears == ageYears &&
      other.heightCm == heightCm &&
      other.weightKg == weightKg &&
      other.sex == sex;

  @override
  int get hashCode => Object.hash(ageYears, heightCm, weightKg, sex);
}

/// Shows the BMI card only once age, height, weight and sex are all in.
///
/// Motion, in order: a short pause so it does not flash mid-typing; the card
/// grows open (height, fade, a small rise and 0.96→1 scale, ease-out-quart);
/// then the ring sweeps from empty while the number counts up, and the
/// status fades in as the sweep settles. Later edits re-tween from the
/// current value. Clearing a field waits a moment before closing, so a quick
/// correction does not collapse the card. Reduce Motion shows and hides it
/// instantly. When the keyboard is down, the page scrolls the new card into
/// view.
class ProfileBmiReveal extends StatefulWidget {
  const ProfileBmiReveal({
    super.key,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    required this.sex,
  });

  final int? ageYears;
  final double? heightCm;
  final double? weightKg;
  final ProfileSex? sex;

  @override
  State<ProfileBmiReveal> createState() => _ProfileBmiRevealState();
}

class _ProfileBmiRevealState extends State<ProfileBmiReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.bmiReveal,
  )..addStatusListener(_onRevealStatus);
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _reveal,
    curve: AppMotion.bmiRevealCurve,
    reverseCurve: Curves.easeInCubic,
  );
  Timer? _timer;
  ProfileBmiInput? _shown;

  /// Bumped on each reveal so the ring sweeps from empty again.
  int _generation = 0;

  ProfileBmiInput? get _input => ProfileBmiInput.from(
    ageYears: widget.ageYears,
    heightCm: widget.heightCm,
    weightKg: widget.weightKg,
    sex: widget.sex,
  );

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reveal.duration = _reduceMotion ? Duration.zero : AppMotion.bmiReveal;
    _sync();
  }

  @override
  void didUpdateWidget(ProfileBmiReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curve.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _sync() {
    final input = _input;
    final open =
        _reveal.status == AnimationStatus.forward ||
        _reveal.status == AnimationStatus.completed;
    if (input != null && open) {
      // Already visible: update the reading in place.
      _timer?.cancel();
      _timer = null;
      _shown = input;
      return;
    }
    if (input != null) {
      _schedule(AppMotion.bmiShowDelay, _show);
    } else if (open) {
      _schedule(AppMotion.bmiHideDelay, () => _reveal.reverse());
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _schedule(Duration delay, VoidCallback action) {
    _timer?.cancel();
    if (_reduceMotion) {
      _timer = null;
      action();
      return;
    }
    _timer = Timer(delay, () {
      _timer = null;
      if (mounted) action();
    });
  }

  void _show() {
    final input = _input;
    if (input == null) return;
    void apply() {
      _shown = input;
      _generation++;
    }

    if (_reduceMotion || _building) {
      apply();
    } else {
      setState(apply);
    }
    _reveal.forward();
  }

  // With Reduce Motion the controller settles synchronously inside
  // didUpdateWidget, where a setState is not allowed; the pending build
  // picks the change up instead.
  bool get _building =>
      SchedulerBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks;

  void _onRevealStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.dismissed) {
      if (_building) {
        _shown = null;
      } else {
        setState(() => _shown = null);
      }
    }
    if (status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || MediaQuery.viewInsetsOf(context).bottom > 0) return;
        // Keyboard is down: bring the new card into view.
        Scrollable.ensureVisible(
          context,
          duration: _reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    if (shown == null || _reveal.isDismissed) return const SizedBox.shrink();
    final rise = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_curve);
    final scale = Tween(begin: 0.96, end: 1.0).animate(_curve);
    final fade = CurvedAnimation(
      parent: _reveal,
      curve: const Interval(0.15, 1, curve: Curves.easeOut),
    );
    // Grow by Align.heightFactor rather than SizeTransition: the clip is
    // only applied while opening or closing, so the settled card keeps its
    // full glass shadow and no clipped edge shows under it.
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, child) => ClipRect(
        clipBehavior: _reveal.isAnimating ? Clip.hardEdge : Clip.none,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: _curve.value,
          child: child,
        ),
      ),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: rise,
          child: ScaleTransition(
            scale: scale,
            child: ProfileBmiCard(
              key: ValueKey(_generation),
              input: shown,
              animate: !_reduceMotion,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reading shown on the BMI card.
final class _BmiReading {
  const _BmiReading({
    required this.bmi,
    required this.status,
    required this.color,
    this.note,
  });

  final double bmi;
  final String status;
  final Color color;
  final String? note;
}

_BmiReading _readBmi(AppLocalizations strings, ProfileBmiInput input) {
  final bmi = bodyMassIndex(
    weightKg: input.weightKg,
    heightCm: input.heightCm,
  )!;
  if (input.ageYears < BodyLimits.adultAge) {
    final status = teenBmiStatus(
      ageYears: input.ageYears,
      sex: input.sex,
      heightCm: input.heightCm,
      weightKg: input.weightKg,
    );
    return switch (status) {
      TeenBmiStatus.underweight => _BmiReading(
        bmi: bmi,
        status: strings.profileTeenBmiStatusUnderweight,
        color: AppColors.chartGold,
      ),
      TeenBmiStatus.healthy => _BmiReading(
        bmi: bmi,
        status: strings.profileTeenBmiStatusHealthy,
        color: AppColors.primary,
      ),
      TeenBmiStatus.overweight => _BmiReading(
        bmi: bmi,
        status: strings.profileTeenBmiStatusOverweight,
        color: AppColors.chartGold,
      ),
      TeenBmiStatus.obesity => _BmiReading(
        bmi: bmi,
        status: strings.profileTeenBmiStatusObesity,
        color: AppColors.destructive,
      ),
      null => _BmiReading(
        bmi: bmi,
        status: strings.profileBmiTeenHint,
        color: AppColors.mutedForeground,
      ),
    };
  }
  final note = strings.profileBmiAsianNote;
  return switch (adultBmiCategory(bmi)) {
    AdultBmiCategory.underweight => _BmiReading(
      bmi: bmi,
      status: strings.profileBmiAdultUnderweight,
      color: AppColors.chartGold,
      note: note,
    ),
    AdultBmiCategory.healthy => _BmiReading(
      bmi: bmi,
      status: strings.profileBmiAdultHealthy,
      color: AppColors.primary,
      note: note,
    ),
    AdultBmiCategory.overweight => _BmiReading(
      bmi: bmi,
      status: strings.profileBmiAdultOverweight,
      color: AppColors.chartGold,
      note: note,
    ),
    AdultBmiCategory.obesity => _BmiReading(
      bmi: bmi,
      status: strings.profileBmiAdultObesity,
      color: AppColors.destructive,
      note: note,
    ),
  };
}

/// Fixed scale for the BMI ring, so a normal reading stays visibly short of
/// full; it is a display scale, not a cut-off.
const _ringMaxBmi = 30.0;

/// Glass card with a BMI ring that fills against [_ringMaxBmi]. With
/// [animate], the ring sweeps and the number counts up from zero on first
/// build, then tweens between later values.
class ProfileBmiCard extends StatelessWidget {
  const ProfileBmiCard({super.key, required this.input, this.animate = true});

  final ProfileBmiInput input;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final reading = _readBmi(strings, input);
    final formatter = NumberFormat.decimalPattern(strings.localeName)
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
    final value = formatter.format(reading.bmi);
    return Semantics(
      key: const Key('profile-body-insight'),
      container: true,
      liveRegion: true,
      label: '${strings.profileBmiEstimateTitle} $value, ${reading.status}',
      excludeSemantics: true,
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0 : reading.bmi, end: reading.bmi),
          duration: animate ? AppMotion.bmiRing : Duration.zero,
          // The sweep starts as the card finishes opening.
          curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
          builder: (context, shownBmi, _) {
            final settled = reading.bmi == 0
                ? 1.0
                // Fades in over the last part of the first sweep; small
                // later edits stay above the threshold and do not flicker.
                : ((shownBmi / reading.bmi - 0.5) / 0.3).clamp(0.0, 1.0);
            return Row(
              spacing: AppSpacing.md,
              children: [
                CustomPaint(
                  size: const Size.square(AppSizes.voiceMascot),
                  painter: _BmiRingPainter(
                    fraction: (shownBmi / _ringMaxBmi).clamp(0.0, 1.0),
                    color: reading.color,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.profileBmiEstimateTitle,
                        style: AppTypography.label,
                      ),
                      Text(
                        // Exact value once settled, so the text matches.
                        settled >= 1 ? value : formatter.format(shownBmi),
                        style: AppTypography.numericLarge.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1.25,
                        ),
                      ),
                      Opacity(
                        opacity: settled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reading.status,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                color: AppColors.primary,
                              ),
                            ),
                            if (reading.note case final note?) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(note, style: AppTypography.caption),
                            ],
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              strings.profileBmiDisclaimer,
                              style: AppTypography.caption.copyWith(
                                height: 1.625,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BmiRingPainter extends CustomPainter {
  const _BmiRingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG geometry: r=42, stroke-width=10 in a 100 unit box.
    final scale = size.shortestSide / 100;
    final stroke = 10 * scale;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: 42 * scale,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.muted;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_BmiRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
