import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Loudness processing and per-bar heights; notifies the painter directly so
/// a frame repaints the canvas without rebuilding widgets.
class VoiceWaveModel extends ChangeNotifier {
  VoiceWaveModel({this.bars = defaultBars, this.bellWidth = 0.26})
    : heights = List<double>.filled(bars, 0);

  static const defaultBars = 64;

  final int bars;

  /// Width of the centre-weighted bell; larger keeps the edges livelier.
  final double bellWidth;

  /// Speech must exceed the learned room noise by this much (≈4 dB on iOS).
  static const _gate = 0.08;

  /// Level span above the gate that maps to a full-height wave (≈17 dB).
  static const _span = 0.35;

  /// Bar heights 0..1, eased toward their targets.
  final List<double> heights;

  double _floor = -1;
  double _envelope = 0;
  double _time = 0;

  bool get atRest => _envelope < 0.002 && heights.every((h) => h < 0.002);

  /// [level] is the raw 0..1 loudness, or null once listening has ended.
  void advance(double dt, {required double? level}) {
    final speech = level == null ? 0.0 : _speech(level, dt);
    // Fast attack, slower release, like a VU meter.
    final time = speech > _envelope ? 0.06 : 0.32;
    _envelope += (speech - _envelope) * (1 - math.exp(-dt / time));
    // Ripples travel faster while speaking and stay calm in silence.
    _time += dt * (0.6 + 1.6 * _envelope);

    final ease = 1 - math.exp(-dt / 0.09);
    for (var i = 0; i < bars; i++) {
      final x = bars == 1 ? 0.5 : i / (bars - 1);
      // Bell shape: tallest in the middle, low towards the edges.
      final bell = math.exp(-math.pow((x - 0.5) / bellWidth, 2));
      final ripple =
          0.68 +
          0.2 * math.sin(x * 19 - _time * 5.1) +
          0.14 * math.sin(x * 37 + _time * 3.3);
      final target = (_envelope * bell * ripple).clamp(0.0, 1.0);
      heights[i] += (target - heights[i]) * ease;
    }
    notifyListeners();
  }

  /// Learns the room noise floor and returns only the part above it.
  double _speech(double level, double dt) {
    if (_floor < 0) _floor = level;
    // Drop to quieter levels quickly; rise slowly so speech is not learned.
    final time = level < _floor ? 0.15 : 6.0;
    _floor += (level - _floor) * (1 - math.exp(-dt / time));
    final above = ((level - _floor - _gate) / _span).clamp(0.0, 1.0);
    // Ease-out lifts soft speech without letting noise through.
    return 1 - math.pow(1 - above, 2).toDouble();
  }

  void reset() {
    heights.fillRange(0, bars, 0);
    _envelope = 0;
    _floor = -1;
    notifyListeners();
  }
}
