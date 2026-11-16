import 'dart:async';

import 'package:lanh_app/features/onboarding/domain/onboarding_repository.dart';

class TestOnboardingRepository implements OnboardingRepository {
  bool completed = false;
  bool failWrite = false;
  bool failRead = false;
  int writes = 0;
  Completer<void>? writeGate;
  Completer<void>? readGate;

  @override
  Future<bool> hasCompletedIntroduction() async {
    if (readGate != null) await readGate!.future;
    if (failRead) throw StateError('Test storage read unavailable');
    return completed;
  }

  @override
  Future<void> completeIntroduction() async {
    writes++;
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw StateError('Test storage unavailable');
    completed = true;
  }
}
