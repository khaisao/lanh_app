import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/meal_analysis.dart';
import '../domain/meal_photo_repository.dart';
import 'meal_camera.dart';

enum MealPhotoStage {
  checking,
  permission,
  camera,
  review,
  estimating,
  estimationError,
  result,
}

/// Whole-meal portion choices from meal-review.html.
const mealPortionScales = [0.5, 1.0, 1.5];

enum MealPhotoIssue {
  camera,
  cameraSwitch,
  capture,
  captureTimeout,
  gallery,
  settings,
}

class MealPhotoController extends ChangeNotifier {
  MealPhotoController(
    this._repository,
    this._openCamera, {
    MealPhoto? recoveredPhoto,
    required this._isActive,
    required this._analysis,
    this._preparePhoto,
  }) : photo = recoveredPhoto,
       stage = recoveredPhoto == null
           ? MealPhotoStage.checking
           : MealPhotoStage.review;

  static const captureTimeout = Duration(seconds: 15);

  final MealPhotoRepository _repository;
  final MealAnalysisRepository _analysis;
  final MealCameraFactory _openCamera;
  final Future<void> Function(MealPhoto)? _preparePhoto;
  int _operationVersion = 0;
  int _cameraEpoch = 0;
  MealPhotoIssue? _operation;
  var _cameraWork = Future<void>.value();
  var _source = MealPhotoStage.permission;
  var _disposed = false;
  var _waitingForSettings = false;
  var _resumedFromSettings = false;
  var _picking = false;
  int _estimationVersion = 0;
  Completer<void>? _estimationCancel;
  String? _requestId;
  bool _isActive;
  var _facing = MealCameraFacing.back;

  MealPhotoStage stage;
  MealCameraAccess? access;
  MealCamera? camera;
  MealPhoto? photo;
  MealPhotoIssue? issue;
  MealAnalysis? analysis;
  MealAnalysisFailureKind? estimationFailure;
  double portionScale = 1;
  bool busy = false;
  bool captured = false;
  bool requested = false;
  bool get capturing => busy && _operation == MealPhotoIssue.capture;
  bool get loadingPhoto => busy && _operation == MealPhotoIssue.gallery;
  bool get switchingCamera => busy && _operation == MealPhotoIssue.cameraSwitch;

  Future<void> switchCamera() async {
    final session = camera;
    if (!_isActive ||
        stage != MealPhotoStage.camera ||
        session == null ||
        !session.canSwitchFacing) {
      return;
    }
    await _run(MealPhotoIssue.cameraSwitch, () async {
      _facing = session.facing == MealCameraFacing.back
          ? MealCameraFacing.front
          : MealCameraFacing.back;
      await _syncCamera(restart: true, fallbackFacing: session.facing);
    });
  }

  Future<void> checkAccess({bool request = false}) =>
      _run(MealPhotoIssue.camera, () async {
        requested |= request;
        final status = await _repository.cameraAccess(request: request);
        if (_disposed) return;
        access = status;
        stage = status == MealCameraAccess.granted
            ? MealPhotoStage.camera
            : MealPhotoStage.permission;
      });

  Future<void> openSettings() => _run(MealPhotoIssue.settings, () async {
    _waitingForSettings = true;
    try {
      if (!await _repository.openSettings()) {
        throw StateError('Could not open app settings.');
      }
    } catch (_) {
      _waitingForSettings = false;
      _resumedFromSettings = false;
      rethrow;
    }
  });

  Future<void> choosePhoto() => _run(MealPhotoIssue.gallery, () async {
    _picking = true;
    try {
      await _syncCamera();
      if (_disposed) return;
      final selection = await _repository.pickPhoto();
      if (selection != null && !_disposed) {
        await _preparePhoto?.call(selection);
        if (!_disposed) _review(selection, captured: false);
      }
    } finally {
      _picking = false;
    }
  });

  Future<void> capturePhoto() => _run(MealPhotoIssue.capture, () async {
    final session = camera;
    if (session == null) return;
    final epoch = _cameraEpoch;
    try {
      final captured = await session.capture().timeout(captureTimeout);
      if (_isCurrentCamera(session, epoch)) {
        await _preparePhoto?.call(captured);
        if (_isCurrentCamera(session, epoch)) {
          _review(captured, captured: true);
        }
      }
    } catch (_) {
      if (_isCurrentCamera(session, epoch)) {
        unawaited(_syncCamera(restart: true));
      }
      rethrow;
    }
  });

  bool _isCurrentCamera(MealCamera session, int epoch) =>
      !_disposed && epoch == _cameraEpoch && identical(camera, session);

  void _review(MealPhoto image, {required bool captured}) {
    if (stage != MealPhotoStage.review) _source = stage;
    this.captured = captured;
    photo = image;
    _requestId = null;
    analysis = null;
    stage = MealPhotoStage.review;
  }

  void returnFromReview() {
    if (busy) return;
    photo = null;
    stage = _source;
    if (stage == MealPhotoStage.permission && access == null) {
      unawaited(checkAccess());
    } else {
      _refresh();
    }
  }

  Future<void> startEstimation() async {
    final image = photo;
    if (_disposed ||
        busy ||
        image == null ||
        (stage != MealPhotoStage.review &&
            stage != MealPhotoStage.estimationError)) {
      return;
    }
    final version = ++_estimationVersion;
    final cancel = _estimationCancel = Completer<void>();
    // One draft identity per photo, so a retry refers to the same request.
    final requestId = _requestId ??= _newRequestId();
    stage = MealPhotoStage.estimating;
    estimationFailure = null;
    analysis = null;
    _refresh();
    MealAnalysisFailureKind? failure;
    MealAnalysis? result;
    try {
      result = await _analysis.analyzePhoto(
        image,
        requestId: requestId,
        cancel: cancel.future,
      );
    } on MealAnalysisFailure catch (error) {
      failure = error.kind;
    } catch (_) {
      failure = MealAnalysisFailureKind.unexpected;
    }
    // A cancelled, replaced or disposed estimate must not change the flow.
    if (_disposed || version != _estimationVersion) return;
    _estimationCancel = null;
    if (result != null) {
      analysis = result;
      portionScale = 1;
      stage = MealPhotoStage.result;
    } else {
      estimationFailure = failure;
      stage = MealPhotoStage.estimationError;
    }
    _refresh();
  }

  void selectPortion(double scale) {
    if (_disposed ||
        stage != MealPhotoStage.result ||
        !mealPortionScales.contains(scale) ||
        scale == portionScale) {
      return;
    }
    portionScale = scale;
    _refresh();
  }

  /// Leaves estimation or its unsaved result and returns to the same photo.
  void returnToPhoto() {
    if (_disposed ||
        (stage != MealPhotoStage.estimating &&
            stage != MealPhotoStage.estimationError &&
            stage != MealPhotoStage.result)) {
      return;
    }
    _cancelEstimation();
    analysis = null;
    estimationFailure = null;
    stage = MealPhotoStage.review;
    _refresh();
  }

  void _cancelEstimation() {
    _estimationVersion++;
    final cancel = _estimationCancel;
    _estimationCancel = null;
    if (cancel != null && !cancel.isCompleted) cancel.complete();
  }

  static String _newRequestId() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void setActive(bool isActive) {
    if (_disposed) return;
    if (_isActive != isActive) _cameraEpoch++;
    _isActive = isActive;
    if (!isActive && capturing) {
      _operationVersion++;
      _operation = null;
      busy = false;
    }
    _resumedFromSettings |= isActive && _waitingForSettings;
    _checkSettingsOnReturn();
    _refresh();
  }

  void _checkSettingsOnReturn() {
    if (_resumedFromSettings && !busy && !_disposed) {
      _waitingForSettings = false;
      _resumedFromSettings = false;
      unawaited(checkAccess());
    }
  }

  Future<void> _run(
    MealPhotoIssue failure,
    Future<void> Function() work,
  ) async {
    if (busy || _disposed) return;
    final version = ++_operationVersion;
    _operation = failure;
    busy = true;
    issue = null;
    notifyListeners();
    try {
      await work();
    } catch (error) {
      if (_disposed || version != _operationVersion) return;
      if (failure == MealPhotoIssue.camera) {
        access = MealCameraAccess.unavailable;
        stage = MealPhotoStage.permission;
      }
      issue = error is TimeoutException && failure == MealPhotoIssue.capture
          ? MealPhotoIssue.captureTimeout
          : failure;
    } finally {
      if (!_disposed && version == _operationVersion) {
        _operation = null;
        busy = false;
        _refresh();
        _checkSettingsOnReturn();
      }
    }
  }

  bool get _needsCamera =>
      !_disposed && _isActive && stage == MealPhotoStage.camera && !_picking;

  void _refresh() {
    unawaited(_syncCamera());
    if (!_disposed) notifyListeners();
  }

  Future<void> _syncCamera({
    bool restart = false,
    MealCameraFacing? fallbackFacing,
  }) {
    if (restart) _cameraEpoch++;
    final previous = _needsCamera && !restart ? null : camera;
    if (previous != null) camera = null;
    _cameraWork = _cameraWork.then((_) async {
      if (previous != null) await _closeCamera(previous);
      if (!_needsCamera || camera != null) return;

      final epoch = _cameraEpoch;
      try {
        final status = await _repository.cameraAccess();
        if (!_needsCamera || epoch != _cameraEpoch) return;
        if (status != MealCameraAccess.granted) {
          access = status;
          stage = MealPhotoStage.permission;
        } else {
          MealCamera session;
          try {
            session = await _openCamera(_facing);
          } catch (_) {
            if (fallbackFacing == null ||
                !_needsCamera ||
                epoch != _cameraEpoch) {
              rethrow;
            }
            _facing = fallbackFacing;
            issue = MealPhotoIssue.cameraSwitch;
            session = await _openCamera(_facing);
          }
          if (_needsCamera && epoch == _cameraEpoch) {
            camera = session;
            _facing = session.facing;
          } else {
            await _closeCamera(session);
          }
        }
      } catch (_) {
        if (!_needsCamera || epoch != _cameraEpoch) return;
        access = MealCameraAccess.unavailable;
        stage = MealPhotoStage.permission;
      }
      if (!_disposed) notifyListeners();
    });
    return _cameraWork;
  }

  Future<void> _closeCamera(MealCamera session) async {
    try {
      await session.close();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    }
  }

  @override
  void dispose() {
    _cancelEstimation();
    _disposed = true;
    _cameraEpoch++;
    unawaited(_syncCamera());
    super.dispose();
  }
}
