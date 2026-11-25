import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';

/// "hôm nay", "hôm qua" or "18/11" for [day] seen from [today].
String weightDayLabel(AppLocalizations strings, DateTime day, DateTime today) {
  // UTC midnights so a daylight-saving change never shifts the count.
  final gap = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(day.year, day.month, day.day)).inDays;
  return switch (gap) {
    0 => strings.dayToday,
    1 => strings.dayYesterday,
    _ => DateFormat('d/M', strings.localeName).format(day),
  };
}
