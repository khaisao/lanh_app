/// Adult body measurements and the BMI reading used by Profile Setup.
///
/// Lành uses the WHO cut-offs for Asian adults, applied from age 20:
/// underweight < 18.5, normal 18.5–22.9, overweight 23–24.9, obesity ≥ 25.
/// Sources: WHO Western Pacific Region/IASO/IOTF, "The Asia-Pacific
/// perspective: redefining obesity and its treatment" (2000), and the WHO
/// Expert Consultation, Lancet 2004;363:157-63, which found risk rising from
/// BMI 23 in Asian populations. Ages 13–19 use the BMI-for-age reference in
/// `teen_bmi.dart`.
library;

/// Plausible ranges for typed values. Outside them the entry is almost
/// certainly a typo (e.g. metres instead of centimetres), so the form asks
/// again instead of computing a misleading BMI.
abstract final class BodyLimits {
  static const minAge = 13;
  static const maxAge = 120;
  static const adultAge = 20;
  static const minHeightCm = 100.0;
  static const maxHeightCm = 250.0;
  static const minWeightKg = 25.0;
  static const maxWeightKg = 350.0;
}

/// WHO cut-offs for Asian adults.
abstract final class BmiThresholds {
  static const underweight = 18.5;
  static const overweight = 23.0;
  static const obesity = 25.0;

  /// Upper end of the normal range, used as the weight-gain ceiling.
  static const healthyMax = 22.9;
}

enum AdultBmiCategory { underweight, healthy, overweight, obesity }

/// Body mass index in kg/m², or null for missing or non-finite input.
double? bodyMassIndex({required double? weightKg, required double? heightCm}) {
  if (weightKg == null || heightCm == null) return null;
  if (!weightKg.isFinite || !heightCm.isFinite) return null;
  if (weightKg <= 0 || heightCm <= 0) return null;
  final metres = heightCm / 100;
  return weightKg / (metres * metres);
}

AdultBmiCategory adultBmiCategory(double bmi) => bmi < BmiThresholds.underweight
    ? AdultBmiCategory.underweight
    : bmi < BmiThresholds.overweight
    ? AdultBmiCategory.healthy
    : bmi < BmiThresholds.obesity
    ? AdultBmiCategory.overweight
    : AdultBmiCategory.obesity;

/// Weight at a BMI for a height, in kg.
double weightAtBmi({required double bmi, required double heightCm}) {
  final metres = heightCm / 100;
  return bmi * metres * metres;
}
