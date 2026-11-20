import 'package:lanh_app/features/water/domain/water_log_repository.dart';

/// In-memory water glasses keyed by local day, with switchable failures.
final class TestWaterLogRepository implements WaterLogRepository {
  final List<(DateTime, int)> logs = [];
  bool failRead = false;
  bool failWrite = false;
  int reads = 0;

  static bool _sameDay(DateTime a, DateTime b) {
    final x = a.toLocal(), y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  @override
  Future<int> countForDate(DateTime date) async {
    reads++;
    if (failRead) throw StateError('read failed');
    return logs.where((log) => _sameDay(log.$1, date)).length;
  }

  @override
  Future<void> add({required DateTime at, required int milliliters}) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (failWrite) throw StateError('write failed');
    logs.add((at, milliliters));
  }

  @override
  Future<void> removeLatestForDate(DateTime date) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (failWrite) throw StateError('write failed');
    final today = logs.where((log) => _sameDay(log.$1, date)).toList();
    if (today.isNotEmpty) logs.remove(today.last);
  }
}
