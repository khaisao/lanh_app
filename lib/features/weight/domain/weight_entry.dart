/// Lowest and highest body weight the app accepts, in kilograms.
const minWeightKg = 20.0;
const maxWeightKg = 300.0;

/// Weight is entered and shown in steps of 0,1 kg.
const weightStepKg = 0.1;

/// How many days back, today included, a weight can be logged or changed.
const weightEditableDays = 14;

/// The local calendar day of [date], at midnight.
DateTime weightDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Rounds [kg] to the 0,1 kg step, or returns null when it is not a finite
/// weight inside [minWeightKg]..[maxWeightKg].
double? normalizeWeightKg(double kg) {
  if (!kg.isFinite) return null;
  final rounded = (kg * 10).round() / 10;
  if (rounded < minWeightKg || rounded > maxWeightKg) return null;
  return rounded;
}

/// One weigh-in. A day holds at most one; saving that day again replaces it.
final class WeightEntry {
  WeightEntry({required DateTime day, required double kg})
    : day = weightDay(day),
      kg = normalizeWeightKg(kg) ?? (throw ArgumentError.value(kg, 'kg'));

  final DateTime day;
  final double kg;

  @override
  bool operator ==(Object other) =>
      other is WeightEntry && other.day == day && other.kg == kg;

  @override
  int get hashCode => Object.hash(day, kg);
}

/// The latest entry on or before [day], from [entries] in any order.
WeightEntry? latestWeightOnOrBefore(
  Iterable<WeightEntry> entries,
  DateTime day,
) {
  final limit = weightDay(day);
  WeightEntry? latest;
  for (final entry in entries) {
    if (entry.day.isAfter(limit)) continue;
    if (latest == null || entry.day.isAfter(latest.day)) latest = entry;
  }
  return latest;
}

abstract interface class WeightRepository {
  /// Entries from [from] to [to], both local days included, newest first.
  Future<List<WeightEntry>> readBetween(DateTime from, DateTime to);

  /// Saves [entry], replacing any entry already saved for that day.
  Future<void> save(WeightEntry entry);

  /// Removes the entry of the local day of [day], if any.
  Future<void> delete(DateTime day);
}
