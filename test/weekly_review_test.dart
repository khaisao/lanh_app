import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/progress/domain/weekly_review.dart';

void main() {
  // Tuesday 24/11/2026: the week is Tue 17 … Mon 23, today excluded.
  final today = DateTime(2026, 11, 24, 9);
  DateTime day(int d) => DateTime(2026, 11, d);

  WeeklyReview review({
    Map<DateTime, double> kcal = const {},
    Map<DateTime, int> water = const {},
    List<ReviewWeight> weights = const [],
    ReviewGoal goal = ReviewGoal.lose,
    int? target = 1600,
    int? waterGoal = 8,
  }) => WeeklyReview.of(
    today: today,
    kcalByDay: kcal,
    waterByDay: water,
    weights: weights,
    goal: goal,
    target: target,
    waterGoal: waterGoal,
  );

  test('covers the seven days before today, oldest first', () {
    final week = review(kcal: {day(24): 900, day(16): 1200, day(17): 1500});
    expect(week.days.first, day(17));
    expect(week.days.last, day(23));
    expect(week.kcal.first, 1500);
    // Today and the day before the week are not part of it.
    expect(week.loggedDays, 1);
  });

  test('averages divide by logged days; missing days are not zero', () {
    final week = review(kcal: {day(17): 1500, day(19): 1700, day(23): 1600});
    expect(week.loggedDays, 3);
    expect(week.thin, isFalse);
    expect(week.averageKcal, 1600);
    expect(week.kcal[1], isNull);
  });

  test('fewer than three logged days is a thin week', () {
    final week = review(kcal: {day(22): 1910, day(23): 1510});
    expect(week.thin, isTrue);
    expect(week.daysToAnalysis, 1);
    expect(review().daysToAnalysis, 3);
    expect(review().averageKcal, isNull);
  });

  test('over the plan depends on the goal', () {
    final kcal = <DateTime, double>{
      day(17): 1600,
      day(18): 1601,
      day(19): 1760,
      day(20): 1761,
    };
    expect(review(kcal: kcal).overDays, 3);
    // Maintain allows +10 %: 1.760 is still inside.
    expect(review(kcal: kcal, goal: ReviewGoal.maintain).overDays, 1);
    expect(review(kcal: kcal, goal: ReviewGoal.gain).overDays, 0);
    expect(review(kcal: kcal, target: null).overDays, 0);
  });

  test('verdict follows the first and last weigh-in of the week', () {
    List<ReviewWeight> w(double a, double b) => [
      (day: day(23), kg: b),
      (day: day(17), kg: a),
      (day: day(10), kg: 60), // before the week
    ];
    expect(review(weights: w(53, 52.8)).verdict, ReviewVerdict.onTrack);
    expect(review(weights: w(53, 53.2)).verdict, ReviewVerdict.offTrack);
    expect(review(weights: w(53, 53)).verdict, ReviewVerdict.offTrack);
    expect(
      review(weights: w(53, 53.2), goal: ReviewGoal.gain).verdict,
      ReviewVerdict.onTrack,
    );
    expect(
      review(weights: w(53, 53.5), goal: ReviewGoal.maintain).verdict,
      ReviewVerdict.onTrack,
    );
    expect(
      review(weights: w(53, 53.6), goal: ReviewGoal.maintain).verdict,
      ReviewVerdict.offTrack,
    );
    expect(
      review(weights: w(53, 52), goal: ReviewGoal.none).verdict,
      ReviewVerdict.unknown,
    );
    expect(
      review(weights: [(day: day(20), kg: 52)]).verdict,
      ReviewVerdict.unknown,
    );
    expect(review(weights: w(53, 52.8)).weights, hasLength(2));
    expect(review(weights: w(53, 52.8)).latestWeight?.kg, 52.8);
    expect(review(weights: w(53, 52.8)).weightChange, closeTo(-0.2, 1e-9));
  });

  test('weekend finding needs both sides and a 200 kcal gap', () {
    // 21 and 22/11/2026 are Saturday and Sunday.
    final gap = review(
      kcal: {day(21): 1930, day(22): 1910, day(19): 1550, day(23): 1510},
    ).weekendGap;
    expect(gap, isNotNull);
    expect(gap!.gap, closeTo(1920 - 1530, 1e-9));
    expect(review(kcal: {day(21): 1700, day(19): 1501}).weekendGap, isNull);
    expect(review(kcal: {day(21): 1700, day(19): 1500}).weekendGap, isNotNull);
    expect(review(kcal: {day(21): 2500, day(22): 2600}).weekendGap, isNull);
  });

  test('water averages logged days and counts days on goal', () {
    final week = review(
      water: {day(17): 8, day(18): 5, day(23): 7, day(24): 8},
    );
    expect(week.waterDays, 3);
    expect(week.averageWater, closeTo(20 / 3, 1e-9));
    expect(week.waterGoalDays, 1);
    expect(review(water: {day(17): 8}, waterGoal: null).waterGoalDays, 0);
  });
}
