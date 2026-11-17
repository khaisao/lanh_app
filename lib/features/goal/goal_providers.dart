import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/preferences_goal_repository.dart';
import 'domain/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => PreferencesGoalRepository(SharedPreferencesAsync()),
);
