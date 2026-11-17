import 'package:lanh_app/features/goal/goal.dart';

enum ProfileSex { female, male }

enum ActivityLevel { sitting, light, moderate, heavy, variable }

class Profile {
  const Profile({
    required this.ageYears,
    required this.heightCm,
    required this.sex,
    required this.activityLevel,
    required this.goal,
  });

  final int ageYears;
  final double heightCm;
  final ProfileSex sex;
  final ActivityLevel activityLevel;
  final Goal goal;
}

abstract interface class ProfileRepository {
  Future<Profile?> read();
  Future<void> save(Profile profile);
}
