part of 'meal_voice_flow.dart';

/// VoiceMealInput's recorder waveform: thin 3 dp bars, symmetric around a
/// hairline, fading at both edges.
///
/// [VoiceWaveModel] removes room noise and smooths the ~10 Hz platform level,
/// so this widget only ticks while listening (and until the bars settle) and
/// repaints its canvas without rebuilding widgets. One instance serves both
/// states: 128 dp tall as the hero, 56 dp as the band above the live words,
/// resized during the morph so the recording feedback never resets. Reduce
/// Motion keeps it still.
class _RecordingWaveform extends StatefulWidget {
  const _RecordingWaveform({
    required this.level,
    required this.listening,
    required this.height,
  });

  final ValueListenable<double> level;
  final bool listening;

  /// 128 dp in the waveform state, 56 dp in the live-text band.
  final double height;

  @override
  State<_RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<_RecordingWaveform>
    with SingleTickerProviderStateMixin {
  final _wave = VoiceWaveModel();
  late final Ticker _ticker = createTicker(_onTick);
  Duration? _last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_RecordingWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
      _wave.reset();
    } else if (widget.listening && !_ticker.isActive) {
      _last = null;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    if (last == null) return;
    final dt = (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    _wave.advance(
      math.min(dt, 0.05),
      level: widget.listening ? widget.level.value : null,
    );
    // After listening, run only until the bars have come to rest.
    if (!widget.listening && _wave.atRest) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ShaderMask(
        // `mask-image: linear-gradient(to right, transparent, #000 14%,
        // #000 86%, transparent)`.
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0x00000000),
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: [0, 0.14, 0.86, 1],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: RepaintBoundary(
          child: CustomPaint(painter: _WaveformPainter(_wave)),
        ),
      ),
    ),
  );
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter(this.wave) : super(repaint: wave);

  final VoiceWaveModel wave;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    canvas.drawRect(
      Rect.fromLTWH(0, midY - AppBorders.hairline / 2, size.width, 1),
      Paint()..color = AppColors.border,
    );
    const bar = AppSizes.voiceWaveBar;
    const step = bar * 2;
    final count = math.min(wave.bars, ((size.width + bar) / step).floor());
    if (count <= 0) return;
    final left = (size.width - (count * step - bar)) / 2 + bar / 2;
    final offset = (wave.bars - count) ~/ 2;
    final maxHalf = size.height / 2 - bar / 2;
    final paint = Paint()
      ..strokeWidth = bar
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final height = wave.heights[offset + i];
      // Silence is a row of round dots; speech grows out of the centre line.
      final half = height * maxHalf;
      paint.color = AppColors.primary.withValues(alpha: 0.35 + 0.65 * height);
      final x = left + i * step;
      canvas.drawLine(Offset(x, midY - half), Offset(x, midY + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => oldDelegate.wave != wave;
}
