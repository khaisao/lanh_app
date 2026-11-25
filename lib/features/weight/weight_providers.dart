import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/sqlite_weight_repository.dart';
import 'domain/weight_entry.dart';

final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => SqliteWeightRepository(),
);

/// Weigh-ins of the last year, newest first. Home shows the latest one on
/// or before the day it displays; Nhìn lại reads the week it reviews.
final weightHistoryProvider = FutureProvider<List<WeightEntry>>((ref) {
  final now = DateTime.now();
  final from = DateTime(now.year - 1, now.month, now.day);
  return ref.watch(weightRepositoryProvider).readBetween(from, now);
});

final weightEditorProvider = Provider<WeightEditor>(WeightEditor.new);

/// Saves and removes weigh-ins, then refreshes [weightHistoryProvider].
/// Failures reach the caller so the sheet can keep its input and retry.
final class WeightEditor {
  const WeightEditor(this._ref);

  final Ref _ref;

  Future<void> save(WeightEntry entry) async {
    await _ref.read(weightRepositoryProvider).save(entry);
    _ref.invalidate(weightHistoryProvider);
  }

  Future<void> delete(DateTime day) async {
    await _ref.read(weightRepositoryProvider).delete(day);
    _ref.invalidate(weightHistoryProvider);
  }
}
