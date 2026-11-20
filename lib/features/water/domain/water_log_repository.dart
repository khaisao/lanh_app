/// Persisted water glasses. Each row is one glass logged at a moment; a day
/// is the local calendar day of [loggedAt].
abstract interface class WaterLogRepository {
  /// Glasses logged on the local day of [date].
  Future<int> countForDate(DateTime date);

  /// Logs one glass of [milliliters] at [at].
  Future<void> add({required DateTime at, required int milliliters});

  /// Removes the most recent glass logged on the local day of [date].
  /// Does nothing when that day has none.
  Future<void> removeLatestForDate(DateTime date);
}
