import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/goal.dart';
import '../goal_providers.dart';

final goalControllerProvider = AsyncNotifierProvider<GoalController, Goal?>(
  GoalController.new,
);

class GoalController extends AsyncNotifier<Goal?> {
  @override
  Future<Goal?> build() => ref.read(goalRepositoryProvider).read();

  Future<void> save(Goal goal) async {
    state = const AsyncLoading();
    try {
      await ref.read(goalRepositoryProvider).save(goal);
      state = AsyncData(goal);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}
