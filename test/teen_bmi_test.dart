import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/profile_setup/domain/profile.dart';
import 'package:lanh_app/features/profile_setup/domain/teen_bmi.dart';

void main() {
  test('uses sex and age specific adolescent BMI bands', () {
    expect(
      teenBmiStatus(
        ageYears: 13,
        sex: ProfileSex.male,
        heightCm: 160,
        weightKg: 42,
      ),
      TeenBmiStatus.healthy,
    );
    expect(
      teenBmiStatus(
        ageYears: 13,
        sex: ProfileSex.female,
        heightCm: 160,
        weightKg: 40,
      ),
      TeenBmiStatus.healthy,
    );
    expect(
      teenBmiStatus(
        ageYears: 19,
        sex: ProfileSex.male,
        heightCm: 180,
        weightKg: 100,
      ),
      TeenBmiStatus.obesity,
    );
  });

  test('does not classify adult ages with teen references', () {
    expect(
      teenBmiStatus(
        ageYears: 20,
        sex: ProfileSex.female,
        heightCm: 165,
        weightKg: 60,
      ),
      isNull,
    );
  });
}
