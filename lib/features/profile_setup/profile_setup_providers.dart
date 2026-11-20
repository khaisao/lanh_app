import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/goal/goal.dart';

import 'data/sqlite_profile_repository.dart';
import 'domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SqliteProfileRepository(),
);

final savedProfileProvider = FutureProvider<Profile?>(
  (ref) => ref.watch(profileRepositoryProvider).read(),
  retry: (_, _) => null,
);

final profileGoalProvider = Provider<AsyncValue<Goal?>>((ref) {
  final profile = ref.watch(savedProfileProvider);
  if (profile.hasValue && profile.value == null) {
    return ref.watch(goalControllerProvider);
  }
  return profile.whenData((value) => value?.goal);
});

/// The saved profile's sex, or null before a profile is read.
final profileSexProvider = Provider<ProfileSex?>(
  (ref) => ref.watch(savedProfileProvider).value?.sex,
);

/// The confirmed daily kcal target, or null when none was chosen.
final profileEnergyTargetProvider = Provider<int?>(
  (ref) => ref.watch(savedProfileProvider).value?.dailyEnergyKcal,
);
