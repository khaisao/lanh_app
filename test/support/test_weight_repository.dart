import 'package:lanh_app/features/weight/domain/weight_entry.dart';

/// In-memory weigh-ins, one per day, with switchable failures.
final class TestWeightRepository implements WeightRepository {
  final Map<DateTime, WeightEntry> entries = {};
  bool failRead = false;
  bool failWrite = false;

  @override
  Future<List<WeightEntry>> readBetween(DateTime from, DateTime to) async {
    if (failRead) throw StateError('read failed');
    final start = weightDay(from), end = weightDay(to);
    return entries.values
        .where((e) => !e.day.isBefore(start) && !e.day.isAfter(end))
        .toList()
      ..sort((a, b) => b.day.compareTo(a.day));
  }

  @override
  Future<void> save(WeightEntry entry) async {
    if (failWrite) throw StateError('write failed');
    entries[entry.day] = entry;
  }

  @override
  Future<void> delete(DateTime day) async {
    if (failWrite) throw StateError('write failed');
    entries.remove(weightDay(day));
  }
}
