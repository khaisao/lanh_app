import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../data/device_meal_photo_repository.dart';
import '../domain/meal_photo_repository.dart';
import 'meal_camera.dart';
import 'meal_photo_controller.dart';
import 'meal_photo_image.dart';

part 'meal_photo_views.dart';

final mealPhotoRepositoryProvider = Provider<MealPhotoRepository>(
  (ref) => DeviceMealPhotoRepository(),
);

final mealCameraFactoryProvider = Provider<MealCameraFactory>(
  (ref) => openDeviceMealCamera,
);

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
    final media = stage == MealPhotoStage.camera || reviewing;
    final busy = _controller.busy;
    final choose = busy ? null : _controller.choosePhoto;
    void close() => Navigator.of(context).pop();

    return PopScope<void>(
      canPop: !reviewing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && reviewing) _controller.returnFromReview();
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
              onEstimate: () => _notice(strings.mealPhotoEstimateUnavailable),
              onReplace: busy
                  ? null
                  : _controller.captured
                  ? _controller.returnFromReview
                  : choose,
            ),
          },
        ),
      ),
    );
  }
}
