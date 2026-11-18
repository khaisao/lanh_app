import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_voice_wave_model.dart';

void main() {
  const frame = 1 / 60;

  void run(VoiceWaveModel wave, double seconds, double? Function(int) level) {
    for (var i = 0; i < seconds / frame; i++) {
      wave.advance(frame, level: level(i));
    }
  }

  double tallest(VoiceWaveModel wave) =>
      wave.heights.reduce((a, b) => a > b ? a : b);

  // Room noise measured on an iPhone 15 Plus: 0.12–0.19 (about -44..-40 dBFS).
  double room(int i) => 0.12 + 0.07 * ((i * 7) % 10) / 10;

  test('room noise stays flat', () {
    final wave = VoiceWaveModel();
    run(wave, 4, room);
    expect(tallest(wave), lessThan(0.03));
  });

  test('speech above the room noise raises a centred wave', () {
    final wave = VoiceWaveModel();
    run(wave, 3, room);
    run(wave, 0.6, (_) => 0.55);
    final middle = wave.heights[VoiceWaveModel.defaultBars ~/ 2];
    expect(tallest(wave), greaterThan(0.4));
    expect(middle, greaterThan(wave.heights.first * 4));
  });

  test('a steady loud room is learned as noise over time', () {
    final wave = VoiceWaveModel();
    run(wave, 18, (_) => 0.45);
    expect(tallest(wave), lessThan(0.05));
  });

  test('bars ease back to rest after listening ends', () {
    final wave = VoiceWaveModel();
    run(wave, 2, room);
    run(wave, 1, (_) => 0.6);
    expect(wave.atRest, isFalse);
    run(wave, 2.5, (_) => null);
    expect(wave.atRest, isTrue);
  });

  test('heights change gradually between frames', () {
    final wave = VoiceWaveModel();
    run(wave, 2, room);
    final before = List.of(wave.heights);
    wave.advance(frame, level: 0.9);
    for (var i = 0; i < before.length; i++) {
      expect((wave.heights[i] - before[i]).abs(), lessThan(0.2));
    }
  });
}
