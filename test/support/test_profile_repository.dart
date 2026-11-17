import 'package:lanh_app/features/profile_setup/domain/profile.dart';

class TestProfileRepository implements ProfileRepository {
  Profile? profile;
  bool failWrite = false;

  @override
  Future<Profile?> read() async => profile;

  @override
  Future<void> save(Profile profile) async {
    if (failWrite) throw StateError('Test write failure');
    this.profile = profile;
  }
}
