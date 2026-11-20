import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/meal_voice_recognizer.dart';
import '../domain/meal_log.dart';
import '../domain/meal_analysis.dart' show maxMealDescriptionLength;
import '../meal_logging_providers.dart';
import 'meal_photo_flow.dart'
    show MealAnalysisResultScreen, MealEstimationScreen;
import 'meal_voice_controller.dart';
import 'meal_voice_wave_model.dart';

part 'meal_voice_input_view.dart';
part 'meal_voice_confirm_view.dart';
part 'meal_voice_parts.dart';
part 'meal_voice_waveform.dart';

Future<void> showMealVoiceFlow(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const MealVoiceFlow(),
    ),
  );
}

class MealVoiceFlow extends ConsumerStatefulWidget {
  const MealVoiceFlow({super.key});

  @override
  ConsumerState<MealVoiceFlow> createState() => _MealVoiceFlowState();
}

class _MealVoiceFlowState extends ConsumerState<MealVoiceFlow> {
  late final MealVoiceController _controller;
  late final AppLifecycleListener _lifecycle;
  bool _started = false;
  bool _savingMeal = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final active = state == AppLifecycleState.resumed;
        _controller.setActive(active);
        // Returning from Settings may have granted access.
        if (active) unawaited(_controller.refreshAccess());
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _controller = MealVoiceController(
      ref.read(mealVoiceRecognizerProvider),
      ref.read(mealAnalysisRepositoryProvider),
      languageCode: Localizations.localeOf(context).languageCode,
    )..addListener(_onChange);
    // Wait for the route transition so the system prompt and audio session
    // do not start under an animating page.
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      unawaited(Future.microtask(_controller.start));
    } else {
      void onStatus(AnimationStatus status) {
        if (!status.isCompleted) return;
        animation.removeStatusListener(onStatus);
        if (mounted) unawaited(_controller.start());
      }

      animation.addStatusListener(onStatus);
    }
  }

  void _onChange() {
    if (!mounted) return;
    if (_controller.settingsFailed) {
      _controller.settingsFailed = false;
      _notice(AppLocalizations.of(context).mealPhotoSettingsError);
    }
    setState(() {});
  }

  void _notice(String message) {
    final strings = AppLocalizations.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, AppSizes.action),
              ),
              child: Text(strings.close),
            ),
          ],
        ),
      ),
    );
  }

  /// X and Hủy ghi: stop recording and return to the tab that opened the
  /// task, like the photo flow.
  void _close() {
    // The recognizer releases the microphone in the background.
    unawaited(_controller.cancelListening());
    Navigator.of(context).pop();
  }

  Future<void> _saveMeal() async {
    if (_savingMeal) return;
    final analysis = _controller.analysis;
    if (analysis == null || !mounted) return;
    setState(() => _savingMeal = true);
    try {
      final saved = await ref
          .read(mealLogRepositoryProvider)
          .save(
            analysis: analysis,
            source: MealLogSource.voice,
            portionScale: _controller.portionScale,
          );
      ref.read(lastSavedMealProvider.notifier).record(saved);
      ref.invalidate(todayMealLogsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingMeal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mealReviewSaveError),
        ),
      );
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final stage = controller.stage;
    final estimating =
        stage == MealVoiceStage.estimating ||
        stage == MealVoiceStage.estimationError ||
        stage == MealVoiceStage.result;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (estimating) {
          if (!_savingMeal) controller.returnToDraft();
        } else if (stage == MealVoiceStage.confirm) {
          controller.returnToInput();
        } else {
          _close();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: stage == MealVoiceStage.confirm
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: switch (stage) {
          MealVoiceStage.checking ||
          MealVoiceStage.idle ||
          MealVoiceStage.listening ||
          MealVoiceStage.finishing => _MealVoiceInputView(
            controller: controller,
            onClose: _close,
          ),
          MealVoiceStage.confirm => _MealVoiceConfirmView(
            controller: controller,
          ),
          MealVoiceStage.estimating ||
          MealVoiceStage.estimationError => MealEstimationScreen(
            failed: stage == MealVoiceStage.estimationError,
            failure: controller.estimationFailure,
            onBack: controller.returnToDraft,
            onRetry: controller.startEstimation,
          ),
          MealVoiceStage.result => MealAnalysisResultScreen(
            analysis: controller.analysis!,
            portionScale: controller.portionScale,
            onPortion: controller.selectPortion,
            onBack: controller.returnToDraft,
            onDiscard: _close,
            onSave: _savingMeal ? null : _saveMeal,
            saving: _savingMeal,
          ),
        },
      ),
    );
  }
}
