import 'goal.dart';

abstract interface class GoalRepository {
  Future<Goal?> read();
  Future<void> save(Goal goal);
}
