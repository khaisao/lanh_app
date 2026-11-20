import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';

import 'data/sqlite_water_log_repository.dart';
import 'domain/water_goal.dart';
import 'domain/water_log_repository.dart';

final waterLogRepositoryProvider = Provider<WaterLogRepository>(
  (ref) => SqliteWaterLogRepository(),
);

/// Today's goal in glasses from the saved profile; null until it is read.
final waterGoalGlassesProvider = Provider<int?>((ref) {
  final sex = ref.watch(profileSexProvider);
  return sex == null
      ? null
      : waterGoalGlasses(female: sex == ProfileSex.female);
});

/// Glasses logged today, persisted on the device.
final todayWaterProvider = AsyncNotifierProvider<TodayWater, int>(
  TodayWater.new,
);

class TodayWater extends AsyncNotifier<int> {
  Future<void> _pending = Future.value();

  @override
  Future<int> build() =>
      ref.watch(waterLogRepositoryProvider).countForDate(DateTime.now());

  /// Logs one glass, unless today's goal is already met.
  Future<void> add() => _change(1);

  /// Removes today's most recent glass, if any.
  Future<void> remove() => _change(-1);

  /// Changes run one after another so fast taps never race. The count
  /// updates at once; a failed write restores it and rethrows.
  Future<void> _change(int delta) {
    final run = _pending.then((_) async {
      final current = state.value;
      if (current == null) return;
      final goal = ref.read(waterGoalGlassesProvider);
      if (delta > 0 && (goal == null || current >= goal)) return;
      if (delta < 0 && current == 0) return;
      state = AsyncData(current + delta);
      final repository = ref.read(waterLogRepositoryProvider);
      try {
        final now = DateTime.now();
        if (delta > 0) {
          await repository.add(at: now, milliliters: waterGlassMilliliters);
        } else {
          await repository.removeLatestForDate(now);
        }
      } catch (_) {
        if (ref.mounted) state = AsyncData(current);
        rethrow;
      }
    });
    _pending = run.catchError((Object _) {});
    return run;
  }
}
