import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/meal_photo_repository.dart';
import 'meal_camera.dart';

enum MealPhotoStage { checking, permission, camera, review }

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
    this._preparePhoto,
  }) : photo = recoveredPhoto,
       stage = recoveredPhoto == null
           ? MealPhotoStage.checking
           : MealPhotoStage.review;

  static const captureTimeout = Duration(seconds: 15);

  final MealPhotoRepository _repository;
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
  bool _isActive;
  var _facing = MealCameraFacing.back;

  MealPhotoStage stage;
  MealCameraAccess? access;
  MealCamera? camera;
  MealPhoto? photo;
  MealPhotoIssue? issue;
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
    _disposed = true;
    _cameraEpoch++;
    unawaited(_syncCamera());
    super.dispose();
  }
}
