import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_voice_recognizer.dart';
import 'package:lanh_app/features/meal_logging/presentation/meal_voice_controller.dart';

import 'support/test_meal_analysis_repository.dart';
import 'support/test_meal_voice_recognizer.dart';

void main() {
  late TestMealVoiceRecognizer recognizer;
  late TestMealAnalysisRepository analysis;
  late MealVoiceController controller;

  setUp(() {
    recognizer = TestMealVoiceRecognizer();
    analysis = TestMealAnalysisRepository();
    controller = MealVoiceController(recognizer, analysis, languageCode: 'vi');
  });

  tearDown(() => controller.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('starts listening right away when access is granted', () async {
    await controller.start();
    expect(controller.stage, MealVoiceStage.listening);
    expect(recognizer.languages, ['vi']);
  });

  test('asks for access on the recording screen and then listens', () async {
    recognizer
      ..status = MealVoiceAccess.denied
      ..statusAfterRequest = MealVoiceAccess.granted;
    final pending = controller.start();
    expect(controller.stage, MealVoiceStage.checking);
    await pending;
    expect(recognizer.requests, 1);
    expect(controller.stage, MealVoiceStage.listening);
  });

  test('a refusal stays on the same screen with settings and typing', () async {
    recognizer.status = MealVoiceAccess.denied;
    await controller.start();
    expect(controller.stage, MealVoiceStage.idle);
    expect(controller.access, MealVoiceAccess.denied);
    expect(recognizer.listening, isFalse);

    // The microphone button asks again instead of starting a session.
    await controller.record();
    expect(recognizer.requests, 2);
    expect(recognizer.listening, isFalse);

    await controller.openSettings();
    expect(recognizer.settingsOpened, 1);

    controller.typeInstead();
    expect(controller.stage, MealVoiceStage.confirm);
    expect(controller.typed, isTrue);
    expect(controller.canSend, isFalse);
  });

  test('access granted in Settings starts listening on return', () async {
    recognizer.status = MealVoiceAccess.denied;
    await controller.start();
    recognizer.status = MealVoiceAccess.granted;
    await controller.refreshAccess();
    expect(controller.stage, MealVoiceStage.listening);
    expect(recognizer.requests, 1);
  });

  test('stop keeps the final transcript and opens confirm', () async {
    await controller.start();
    recognizer
      ..hear('Ăn một tô')
      ..level(0.8);
    await settle();
    expect(controller.transcript, 'Ăn một tô');
    expect(controller.level.value, 0.8);

    await controller.stopListening();
    expect(controller.stage, MealVoiceStage.finishing);
    expect(recognizer.stops, 1);
    recognizer.hear('Ăn một tô phở bò tái, thêm ly trà đá', isFinal: true);
    await recognizer.finish();
    await settle();

    expect(controller.stage, MealVoiceStage.confirm);
    expect(controller.draft, 'Ăn một tô phở bò tái, thêm ly trà đá');
    expect(controller.wordCount, 10);
    expect(controller.typed, isFalse);
  });

  test('live text follows each result with normalised spacing', () async {
    await controller.start();
    recognizer.hear('Ăn một tô phở bò tái');
    await settle();
    expect(controller.liveText, 'Ăn một tô phở bò tái');

    recognizer.hear('  Ăn một tô phở  bò tái, thêm ly trà ');
    await settle();
    expect(controller.liveText, 'Ăn một tô phở bò tái, thêm ly trà');
  });

  test('a session with no words returns to idle with a reason', () async {
    await controller.start();
    recognizer.fail(MealVoiceFailureKind.noSpeech);
    await recognizer.finish();
    await settle();
    expect(controller.stage, MealVoiceStage.idle);
    expect(controller.listenFailure, MealVoiceFailureKind.noSpeech);

    await controller.startListening();
    expect(controller.stage, MealVoiceStage.listening);
    expect(controller.listenFailure, isNull);
  });

  test('text heard before a late recognizer error is kept', () async {
    await controller.start();
    recognizer
      ..hear('cơm gà')
      ..fail(MealVoiceFailureKind.recognition);
    await recognizer.finish();
    await settle();
    expect(controller.stage, MealVoiceStage.confirm);
    expect(controller.draft, 'cơm gà');
  });

  test('an unsupported language is reported, not treated as silence', () async {
    await controller.start();
    recognizer.fail(MealVoiceFailureKind.languageUnavailable);
    await recognizer.finish();
    await settle();
    expect(controller.listenFailure, MealVoiceFailureKind.languageUnavailable);
  });

  test('cancel discards the session and ignores later events', () async {
    await controller.start();
    await controller.cancelListening();
    expect(recognizer.cancels, 1);
    await settle();
    expect(controller.stage, isNot(MealVoiceStage.confirm));
  });

  test('leaving the foreground ends listening and keeps the words', () async {
    await controller.start();
    recognizer.hear('bánh mì');
    await settle();
    controller.setActive(false);
    await settle();
    expect(recognizer.stops, 1);
    await recognizer.finish();
    await settle();
    expect(controller.stage, MealVoiceStage.confirm);
    expect(controller.draft, 'bánh mì');
  });

  Future<void> reachConfirm(String text) async {
    await controller.start();
    recognizer.hear(text, isFinal: true);
    await recognizer.finish();
    await settle();
  }

  test('sends only the confirmed, edited text and shows the result', () async {
    await reachConfirm('phở bò');
    controller.updateDraft('  Một tô phở bò tái  ');
    final pending = controller.startEstimation();
    expect(controller.stage, MealVoiceStage.estimating);
    expect(analysis.descriptions, ['Một tô phở bò tái']);

    analysis.succeed();
    await pending;
    expect(controller.stage, MealVoiceStage.result);
    expect(controller.analysis, isNotNull);

    controller.selectPortion(0.5);
    expect(controller.portionScale, 0.5);
  });

  test(
    'retry keeps the request id; editing the text makes a new one',
    () async {
      await reachConfirm('phở bò');
      var pending = controller.startEstimation();
      analysis.fail(MealAnalysisFailureKind.network);
      await pending;
      expect(controller.stage, MealVoiceStage.estimationError);
      expect(controller.estimationFailure, MealAnalysisFailureKind.network);

      pending = controller.startEstimation();
      analysis.fail(MealAnalysisFailureKind.unavailable);
      await pending;
      expect(analysis.requests[0], analysis.requests[1]);

      controller.returnToDraft();
      expect(controller.stage, MealVoiceStage.confirm);
      expect(controller.draft, 'phở bò');
      controller.updateDraft('phở gà');
      pending = controller.startEstimation();
      analysis.succeed();
      await pending;
      expect(analysis.requests[2], isNot(analysis.requests[0]));
    },
  );

  test('going back cancels the request and ignores its late result', () async {
    await reachConfirm('phở bò');
    final pending = controller.startEstimation();
    controller.returnToDraft();
    await settle();
    expect(analysis.cancelled, hasLength(1));
    analysis.succeed();
    await pending;
    expect(controller.stage, MealVoiceStage.confirm);
    expect(controller.analysis, isNull);
  });

  test('empty or overlong drafts cannot be sent', () async {
    await reachConfirm('phở');
    controller.updateDraft('   ');
    expect(controller.canSend, isFalse);
    controller.updateDraft('a' * (maxMealDescriptionLength + 1));
    expect(controller.canSend, isFalse);
    await controller.startEstimation();
    expect(analysis.requests, isEmpty);
  });

  test(
    'back from confirm goes to the idle mic; record again listens',
    () async {
      await reachConfirm('phở');
      controller.returnToInput();
      expect(controller.stage, MealVoiceStage.idle);
      expect(recognizer.languages, hasLength(1));

      await controller.startListening();
      recognizer.hear('bún chả', isFinal: true);
      await recognizer.finish();
      await settle();
      await controller.recordAgain();
      expect(controller.stage, MealVoiceStage.listening);
      expect(recognizer.languages, hasLength(3));
    },
  );
}
