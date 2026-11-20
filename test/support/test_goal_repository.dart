import 'package:lanh_app/features/goal/goal.dart';

class TestGoalRepository implements GoalRepository {
  Goal? value;
  @override
  Future<Goal?> read() async => value;
  @override
  Future<void> save(Goal goal) async => value = goal;
}
