import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/weight_entry.dart';

/// Horizontal ruler for the weight sheet (Sleek "Sheet · Cập nhật cân
/// nặng"): drag it under a fixed center line. One tick per 0,1 kg, a numbered
/// tick per kilogram, snapping to the nearest tick. Screen readers adjust it
/// as a slider, 0,1 kg per swipe.
class WeightRuler extends StatefulWidget {
  const WeightRuler({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    required this.semanticValue,
    this.enabled = true,
  });

  /// Kilograms on a 0,1 grid inside [minWeightKg]..[maxWeightKg].
  final double value;
  final ValueChanged<double> onChanged;
  final String semanticLabel;

  /// Formats a value the way the sheet shows it, for screen readers.
  final String Function(double kg) semanticValue;
  final bool enabled;

  static const tickGap = 10.0;
  static final int _ticks = ((maxWeightKg - minWeightKg) / weightStepKg)
      .round();

  @override
  State<WeightRuler> createState() => _WeightRulerState();
}

class _WeightRulerState extends State<WeightRuler> {
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: _offsetOf(widget.value),
  );
  late int _index = _indexOf(widget.value);

  static int _indexOf(double kg) =>
      ((kg - minWeightKg) / weightStepKg).round().clamp(0, WeightRuler._ticks);

  static double _offsetOf(double kg) => _indexOf(kg) * WeightRuler.tickGap;

  static double _kgOf(int index) =>
      normalizeWeightKg(minWeightKg + index * weightStepKg)!;

  @override
  void didUpdateWidget(WeightRuler old) {
    super.didUpdateWidget(old);
    // A value set from outside (seeding, screen reader) moves the ruler.
    final index = _indexOf(widget.value);
    if (index != _index) {
      _index = index;
      if (_scroll.hasClients) _scroll.jumpTo(_offsetOf(widget.value));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final index = (_scroll.offset / WeightRuler.tickGap).round().clamp(
      0,
      WeightRuler._ticks,
    );
    if (index == _index) return;
    _index = index;
    HapticFeedback.selectionClick();
    widget.onChanged(_kgOf(index));
  }

  bool _snap(ScrollEndNotification _) {
    final target = _index * WeightRuler.tickGap;
    if ((_scroll.offset - target).abs() > 0.5) {
      // Post-frame: a scroll cannot start inside its own end notification.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        if (MediaQuery.disableAnimationsOf(context)) {
          _scroll.jumpTo(target);
        } else {
          _scroll.animateTo(
            target,
            duration: AppMotion.feedbackDuration(context),
            curve: Curves.easeOut,
          );
        }
      });
    }
    return false;
  }

  void _stepBy(int ticks) {
    final index = (_index + ticks).clamp(0, WeightRuler._ticks);
    if (index != _index) widget.onChanged(_kgOf(index));
  }

  @override
  Widget build(BuildContext context) {
    final canUp = _index < WeightRuler._ticks;
    final canDown = _index > 0;
    return Semantics(
      container: true,
      slider: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      value: widget.semanticValue(widget.value),
      increasedValue: canUp ? widget.semanticValue(_kgOf(_index + 1)) : null,
      decreasedValue: canDown ? widget.semanticValue(_kgOf(_index - 1)) : null,
      onIncrease: widget.enabled && canUp ? () => _stepBy(1) : null,
      onDecrease: widget.enabled && canDown ? () => _stepBy(-1) : null,
      child: ExcludeSemantics(
        child: SizedBox(
          height: AppSizes.weightRuler,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = (constraints.maxWidth - WeightRuler.tickGap) / 2;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Ticks fade out toward both edges.
                  ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: [0, 0.25, 0.75, 1],
                    ).createShader(rect),
                    child: NotificationListener<ScrollEndNotification>(
                      onNotification: _snap,
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification: (_) {
                          _onScroll();
                          return false;
                        },
                        child: ListView.builder(
                          key: const Key('weight-ruler'),
                          controller: _scroll,
                          scrollDirection: Axis.horizontal,
                          physics: widget.enabled
                              ? const BouncingScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: side),
                          itemExtent: WeightRuler.tickGap,
                          itemCount: WeightRuler._ticks + 1,
                          itemBuilder: (context, index) => _Tick(
                            index: index,
                            kg: minWeightKg + index * weightStepKg,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // The fixed center line marks the chosen value; drags pass
                  // through it to the ruler.
                  IgnorePointer(
                    child: Container(
                      width: AppSizes.weightRulerIndicator,
                      height: AppSizes.weightRulerMajor + AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.index, required this.kg});

  final int index;
  final double kg;

  @override
  Widget build(BuildContext context) {
    final major = index % 10 == 0;
    final half = index % 5 == 0;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: AppSpacing.xs,
          child: Container(
            width: major ? AppBorders.selected : AppBorders.hairline,
            height: major
                ? AppSizes.weightRulerMajor
                : half
                ? AppSizes.weightRulerHalf
                : AppSizes.weightRulerMinor,
            color: major ? AppColors.mutedForeground : AppColors.border,
          ),
        ),
        if (major)
          Positioned(
            top: AppSpacing.xs + AppSizes.weightRulerMajor + AppSpacing.xxs,
            child: Text(
              kg.round().toString(),
              style: AppTypography.caption,
              maxLines: 1,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}
