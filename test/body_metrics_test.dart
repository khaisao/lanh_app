import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/profile_setup/domain/body_metrics.dart';

void main() {
  test('BMI is kg divided by metres squared', () {
    expect(bodyMassIndex(weightKg: 61.5, heightCm: 165), closeTo(22.59, 0.01));
    expect(bodyMassIndex(weightKg: null, heightCm: 165), isNull);
    expect(bodyMassIndex(weightKg: 60, heightCm: 0), isNull);
    expect(bodyMassIndex(weightKg: double.infinity, heightCm: 165), isNull);
  });

  test('uses the WHO Asian adult cut-offs at their exact boundaries', () {
    expect(adultBmiCategory(18.49), AdultBmiCategory.underweight);
    expect(adultBmiCategory(18.5), AdultBmiCategory.healthy);
    expect(adultBmiCategory(22.99), AdultBmiCategory.healthy);
    expect(adultBmiCategory(23), AdultBmiCategory.overweight);
    expect(adultBmiCategory(24.99), AdultBmiCategory.overweight);
    expect(adultBmiCategory(25), AdultBmiCategory.obesity);
  });

  test('converts a BMI back to weight for a height', () {
    expect(weightAtBmi(bmi: 18.5, heightCm: 165), closeTo(50.37, 0.01));
  });
}
