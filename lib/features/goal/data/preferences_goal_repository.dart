import 'package:shared_preferences/shared_preferences.dart';

import '../domain/goal.dart';
import '../domain/goal_repository.dart';

class PreferencesGoalRepository implements GoalRepository {
  PreferencesGoalRepository(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const _key = 'lanh.goal.v1';

  @override
  Future<Goal?> read() async => Goal.decode(await _preferences.getString(_key));

  @override
  Future<void> save(Goal goal) => _preferences.setString(_key, goal.encode());
}
