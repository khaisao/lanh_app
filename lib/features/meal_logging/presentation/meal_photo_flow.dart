import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../meal_logging_providers.dart';
import '../domain/meal_analysis.dart';
import '../domain/meal_log.dart';
import '../domain/meal_photo_repository.dart';
import 'meal_camera.dart';
import 'meal_photo_controller.dart';
import 'meal_photo_image.dart';

part 'meal_photo_views.dart';
part 'meal_photo_estimation_view.dart';
part 'meal_analysis_result_view.dart';
part 'meal_analysis_result_parts.dart';

final _photoFlowCoordinatorProvider = Provider((ref) {
  final coordinator = _PhotoFlowCoordinator();
  ref.onDispose(() => coordinator.retry?.cancel());
  return coordinator;
});

class _PhotoFlowCoordinator {
  bool active = false;
  Future<void>? recovery;
  Timer? retry;
}

Future<void> showMealPhotoFlow(
  BuildContext context, {
  MealPhoto? recoveredPhoto,
}) async {
  final coordinator = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(_photoFlowCoordinatorProvider);
  final recovery = coordinator.recovery;
  if (recovery != null) await recovery;
  if (!context.mounted) return;
  await _presentMealPhoto(context, coordinator, recoveredPhoto: recoveredPhoto);
}

Future<void> _presentMealPhoto(
  BuildContext context,
  _PhotoFlowCoordinator coordinator, {
  MealPhoto? recoveredPhoto,
}) async {
  if (coordinator.active) return;
  coordinator.retry?.cancel();
  coordinator.active = true;
  final route = MaterialPageRoute<void>(
    fullscreenDialog: true,
    allowSnapshotting: false,
    builder: (_) =>
        AppBackground(child: MealPhotoFlow(recoveredPhoto: recoveredPhoto)),
  );
  try {
    await Navigator.of(context, rootNavigator: true).push<void>(route);
    await route.completed;
  } finally {
    coordinator.active = false;
  }
}

Future<void> restoreMealPhotoFlow(
  BuildContext context, {
  int remainingChecks = 30,
}) async {
  final lifecycle = WidgetsBinding.instance.lifecycleState;
  if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
  final container = ProviderScope.containerOf(context, listen: false);
  final coordinator = container.read(_photoFlowCoordinatorProvider);
  if (coordinator.active || coordinator.recovery != null) return;
  coordinator.retry?.cancel();
  final repository = container.read(mealPhotoRepositoryProvider);
  if (!repository.supportsRecovery) return;
  final recovery = Completer<void>();
  coordinator.recovery = recovery.future;
  Future<void>? presentation;
  try {
    final photo = await repository.recoverPickedPhoto();
    if (photo != null && context.mounted) {
      await prepareMealPhoto(context, photo);
      if (context.mounted) {
        presentation = _presentMealPhoto(
          context,
          coordinator,
          recoveredPhoto: photo,
        );
      }
    } else if (context.mounted && remainingChecks > 0) {
      // Native image copying can finish after the activity's resume callback.
      coordinator.retry = Timer(const Duration(milliseconds: 500), () {
        if (context.mounted && !coordinator.active) {
          unawaited(
            restoreMealPhotoFlow(context, remainingChecks: remainingChecks - 1),
          );
        }
      });
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mealPhotoPickError),
        ),
      );
    }
  } finally {
    coordinator.recovery = null;
    recovery.complete();
  }
  await presentation;
}

class MealPhotoFlow extends ConsumerStatefulWidget {
  const MealPhotoFlow({super.key, this.recoveredPhoto});

  final MealPhoto? recoveredPhoto;

  @override
  ConsumerState<MealPhotoFlow> createState() => _MealPhotoFlowState();
}

class _MealPhotoFlowState extends ConsumerState<MealPhotoFlow> {
  late final MealPhotoController _controller;
  late final AppLifecycleListener _lifecycle;
  Animation<double>? _routeAnimation;
  bool _appActive = true;
  bool _savingMeal = false;

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _appActive = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _controller = MealPhotoController(
      ref.read(mealPhotoRepositoryProvider),
      ref.read(mealCameraFactoryProvider),
      recoveredPhoto: widget.recoveredPhoto,
      isActive: false,
      analysis: ref.read(mealAnalysisRepositoryProvider),
      preparePhoto: (photo) => prepareMealPhoto(context, photo),
    )..addListener(_onChange);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _appActive = state == AppLifecycleState.resumed;
        _updateActive();
      },
    );
    if (widget.recoveredPhoto == null) {
      unawaited(Future.microtask(_controller.checkAccess));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (!identical(animation, _routeAnimation)) {
      _routeAnimation?.removeStatusListener(_onRouteStatus);
      _routeAnimation = animation;
      animation?.addStatusListener(_onRouteStatus);
    }
    _updateActive();
  }

  void _onRouteStatus(AnimationStatus status) => _updateActive();

  void _updateActive() {
    final ready =
        _routeAnimation == null ||
        _routeAnimation!.status == AnimationStatus.completed;
    _controller.setActive(_appActive && ready);
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

  void _onChange() {
    if (!mounted) return;
    final issue = _controller.issue;
    _controller.issue = null;
    final strings = AppLocalizations.of(context);
    switch (issue) {
      case MealPhotoIssue.gallery:
        _notice(strings.mealPhotoPickError);
      case MealPhotoIssue.capture:
        _notice(strings.mealPhotoCaptureError);
      case MealPhotoIssue.cameraSwitch:
        _notice(strings.mealPhotoSwitchError);
      case MealPhotoIssue.captureTimeout:
        _notice(strings.mealPhotoCaptureTimeout);
      case MealPhotoIssue.settings:
        _notice(strings.mealPhotoSettingsError);
      case MealPhotoIssue.camera || null:
        break;
    }
    setState(() {});
  }

  Future<void> _saveMeal() async {
    if (_savingMeal) return;
    final analysis = _controller.analysis;
    final photo = _controller.photo;
    if (analysis == null || photo == null || !mounted) return;
    setState(() => _savingMeal = true);
    try {
      await ref
          .read(mealLogRepositoryProvider)
          .save(
            analysis: analysis,
            source: MealLogSource.photo,
            portionScale: _controller.portionScale,
            photo: photo,
          );
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
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stage = _controller.stage;
    final reviewing = stage == MealPhotoStage.review;
    final estimating =
        stage == MealPhotoStage.estimating ||
        stage == MealPhotoStage.estimationError ||
        stage == MealPhotoStage.result;
    final media = stage == MealPhotoStage.camera;
    final busy = _controller.busy;
    final choose = busy ? null : _controller.choosePhoto;
    void close() => Navigator.of(context).pop();

    return PopScope<void>(
      canPop: !reviewing && !estimating,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (estimating) {
          if (!_savingMeal) _controller.returnToPhoto();
        } else if (reviewing) {
          _controller.returnFromReview();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: media ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: switch (stage) {
            MealPhotoStage.checking => Center(
              child: CircularProgressIndicator(
                semanticsLabel: strings.mealPhotoCameraLoading,
                value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
              ),
            ),
            MealPhotoStage.permission => _MealPhotoPermissionView(
              access: _controller.access,
              busy: busy,
              requested: _controller.requested,
              onBack: close,
              onChoose: choose,
              onRequest: () => _controller.checkAccess(request: true),
              onSettings: _controller.openSettings,
            ),
            MealPhotoStage.camera => _MealCameraView(
              camera: _controller.camera,
              capturing: _controller.capturing,
              loadingPhoto: _controller.loadingPhoto,
              switchingCamera: _controller.switchingCamera,
              onClose: close,
              onChoose: choose,
              onCapture: busy || _controller.camera == null
                  ? null
                  : _controller.capturePhoto,
              canSwitchCamera:
                  _controller.switchingCamera ||
                  (_controller.camera?.canSwitchFacing ?? false),
              onSwitchCamera: busy || _controller.camera == null
                  ? null
                  : _controller.switchCamera,
            ),
            MealPhotoStage.review => _MealPhotoReviewView(
              photo: _controller.photo!,
              captured: _controller.captured,
              loadingPhoto: _controller.loadingPhoto,
              onBack: _controller.returnFromReview,
              onEstimate: busy ? null : _controller.startEstimation,
              onReplace: busy
                  ? null
                  : _controller.captured
                  ? _controller.returnFromReview
                  : choose,
            ),
            MealPhotoStage.estimating ||
            MealPhotoStage.estimationError => _MealPhotoEstimationView(
              photo: _controller.photo!,
              failed: stage == MealPhotoStage.estimationError,
              failure: _controller.estimationFailure,
              onBack: _controller.returnToPhoto,
              onRetry: _controller.startEstimation,
            ),
            MealPhotoStage.result => _MealAnalysisResultView(
              photo: _controller.photo!,
              analysis: _controller.analysis!,
              portionScale: _controller.portionScale,
              onPortion: _controller.selectPortion,
              onBack: _controller.returnToPhoto,
              onDiscard: close,
              onSave: busy || _savingMeal ? null : _saveMeal,
              saving: _savingMeal,
            ),
          },
        ),
      ),
    );
  }
}

/// Estimating/error screen for a described meal (voice or typed text), shared
/// with the photo flow so both sources look and behave the same.
class MealEstimationScreen extends StatelessWidget {
  const MealEstimationScreen({
    super.key,
    required this.failed,
    required this.failure,
    required this.onBack,
    required this.onRetry,
  });

  final bool failed;
  final MealAnalysisFailureKind? failure;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  // A Scaffold supplies the Material text style, as in the photo flow.
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: _MealPhotoEstimationView(
      photo: null,
      failed: failed,
      failure: failure,
      onBack: onBack,
      onRetry: onRetry,
    ),
  );
}

/// Unsaved estimate review for a described meal; see [MealEstimationScreen].
class MealAnalysisResultScreen extends StatelessWidget {
  const MealAnalysisResultScreen({
    super.key,
    required this.analysis,
    required this.portionScale,
    required this.onPortion,
    required this.onBack,
    required this.onDiscard,
    this.onSave,
    this.saving = false,
  });

  final MealAnalysis analysis;
  final double portionScale;
  final ValueChanged<double> onPortion;
  final VoidCallback onBack;
  final VoidCallback onDiscard;
  final Future<void> Function()? onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) => _MealAnalysisResultView(
    photo: null,
    analysis: analysis,
    portionScale: portionScale,
    onPortion: onPortion,
    onBack: onBack,
    onDiscard: onDiscard,
    onSave: onSave,
    saving: saving,
  );
}
