import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/goal.dart';
import '../goal_providers.dart';

final goalControllerProvider = AsyncNotifierProvider<GoalController, Goal?>(
  GoalController.new,
);

class GoalController extends AsyncNotifier<Goal?> {
  @override
  Future<Goal?> build() => ref.read(goalRepositoryProvider).read();
}
