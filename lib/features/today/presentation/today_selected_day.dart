import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The day Home shows: null for today, otherwise a past local day picked in
/// the day strip. Kept as null rather than a date so Home follows the clock
/// into the next day without a stale "today".
final todaySelectedDayProvider = NotifierProvider<TodaySelectedDay, DateTime?>(
  TodaySelectedDay.new,
);

class TodaySelectedDay extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  /// Shows [day]; picking the current day returns to the live today view.
  void select(DateTime day, {required DateTime today}) {
    final picked = DateTime(day.year, day.month, day.day);
    state = picked == DateTime(today.year, today.month, today.day)
        ? null
        : picked;
  }

  void showToday() => state = null;
}
