import 'dart:convert';

enum GoalType { lose, gain, maintain, logOnly }

enum GoalSchedule { byDate, byWeeks, none }

class Goal {
  const Goal({
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.currentWeight,
    this.targetWeight,
    this.referenceWeight,
    this.targetDate,
    this.targetWeeks,
  });

  final GoalType type;
  final double? currentWeight;
  final double? targetWeight;
  final double? referenceWeight;
  final DateTime? targetDate;
  final int? targetWeeks;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalSchedule get schedule => targetDate != null
      ? GoalSchedule.byDate
      : targetWeeks != null
      ? GoalSchedule.byWeeks
      : GoalSchedule.none;

  Map<String, Object?> toJson() => {
    'version': 1,
    'type': type.name,
    'currentWeight': currentWeight,
    'targetWeight': targetWeight,
    'referenceWeight': referenceWeight,
    'targetDate': targetDate?.toIso8601String(),
    'targetWeeks': targetWeeks,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  String encode() => jsonEncode(toJson());

  static Goal? decode(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = GoalType.values.byName(map['type'] as String);
      DateTime? date(String key) =>
          map[key] == null ? null : DateTime.parse(map[key] as String);
      double? number(String key) => (map[key] as num?)?.toDouble();
      return Goal(
        type: type,
        currentWeight: number('currentWeight'),
        targetWeight: number('targetWeight'),
        referenceWeight: number('referenceWeight'),
        targetDate: date('targetDate'),
        targetWeeks: (map['targetWeeks'] as num?)?.toInt(),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
    } on Object {
      return null;
    }
  }
}
