/// Persisted water glasses. Each row is one glass logged at a moment; a day
/// is the local calendar day of [loggedAt].
abstract interface class WaterLogRepository {
  /// Glasses logged on the local day of [date].
  Future<int> countForDate(DateTime date);

  /// Glasses per local day from [from] to [to], both included. Days with
  /// none are absent from the map; keys are local midnights.
  Future<Map<DateTime, int>> countsBetween(DateTime from, DateTime to);

  /// Logs one glass of [milliliters] at [at].
  Future<void> add({required DateTime at, required int milliliters});

  /// Removes the most recent glass logged on the local day of [date].
  /// Does nothing when that day has none.
  Future<void> removeLatestForDate(DateTime date);
}
