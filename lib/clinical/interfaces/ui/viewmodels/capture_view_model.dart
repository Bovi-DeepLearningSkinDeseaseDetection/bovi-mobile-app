import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../shared/infrastructure/camera/native_camera_manager.dart';
import '../../../../shared/infrastructure/network/connectivity_monitor.dart';
import '../../../../shared/infrastructure/persistence/preferences/preferences_app.dart';
import '../../../../shared/infrastructure/sensors/device_motion_monitor.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../widgets/focus_ring.dart';

/// A step of the capture that failed, with the message for the farmer.
class CaptureFailure implements Exception {
  final String message;

  const CaptureFailure(this.message);
}

/// State of the capture screen (HU01, HU02, HU03): the camera, its
/// permission, the steadiness of the phone and the tap to focus.
///
/// It follows the app lifecycle: the camera is released when the app is
/// paused and opened again when it comes back.
class CaptureViewModel extends ChangeNotifier with WidgetsBindingObserver {
  static const _permissionErrorCodes = {
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };
  static const permissionMessage =
      'Bovi necesita acceso a la cámara para fotografiar la lesión '
      'del animal. Puede concederlo desde los ajustes del teléfono.';

  final NativeCameraManager _camera;
  final ApplicationPreferences _preferences;
  final DeviceMotionMonitor _motion;

  /// Whether the device is online, for the header chip.
  final Stream<bool> connection;

  StreamSubscription<bool>? _motionSubscription;
  bool _disposed = false;
  bool _isInitializing = false;

  bool _isLoading = true;
  bool _isBusy = false;
  bool _isSteady = false;
  bool _showFlash = false;
  bool _permissionDenied = false;
  String? _error;
  Offset? _focusPosition;
  int _focusTaps = 0;

  CaptureViewModel({
    NativeCameraManager? camera,
    ApplicationPreferences? preferences,
    DeviceMotionMonitor? motion,
    Stream<bool>? connection,
  }) : _camera = camera ?? NativeCameraManager(),
       _preferences = preferences ?? ApplicationPreferences(),
       _motion = motion ?? DeviceMotionMonitor(),
       connection = connection ?? ConnectivityMonitor().watch();

  CameraController? get controller =>
      _camera.isInitialized ? _camera.controller : null;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  bool get isSteady => _isSteady;
  bool get showFlash => _showFlash;
  bool get permissionDenied => _permissionDenied;
  String? get error => _error;
  Offset? get focusPosition => _focusPosition;

  /// Changes on every tap, so the focus ring replays its animation.
  int get focusTaps => _focusTaps;

  /// Opens the camera and starts following the motion and the lifecycle.
  void start() {
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
    _watchMotion();
  }

  Future<void> initializeCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _isLoading = true;
    _error = null;
    _permissionDenied = false;
    _notify();
    try {
      await _camera.initialize();
    } on CameraException catch (error) {
      if (_permissionErrorCodes.contains(error.code)) {
        _permissionDenied = true;
        _error = permissionMessage;
      } else {
        _error = 'No se pudo iniciar la cámara.';
      }
    } finally {
      _isInitializing = false;
    }
    _isLoading = false;
    _notify();
  }

  // The guide turns green when the phone is steady, with a light tick.
  void _watchMotion() {
    _motionSubscription ??= _motion.watch().listen((steady) {
      if (steady && !_isSteady) HapticFeedback.selectionClick();
      _isSteady = steady;
      _notify();
    });
  }

  void _stopWatchingMotion() {
    _motionSubscription?.cancel();
    _motionSubscription = null;
  }

  // Release the camera when the app is paused and reinitialize it on resume.
  // The permission prompt also pauses the app, so skip while initializing.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopWatchingMotion();
      if (!_camera.isInitialized) return;
      _camera.dispose();
      _isLoading = true;
      _notify();
    } else if (state == AppLifecycleState.resumed) {
      _watchMotion();
      if (!_camera.isInitialized) initializeCamera();
    }
  }

  Future<bool> shouldShowHelp() async => !await _preferences.hasSeenHelpFrame();

  Future<void> markHelpAsSeen() => _preferences.markHelpFrameAsSeen();

  /// Runs [action] unless another one is running, so a second tap on the
  /// shutter or the gallery is ignored until the first one ends.
  Future<void> whileBusy(Future<void> Function() action) async {
    if (_isBusy) return;
    _isBusy = true;
    _notify();
    try {
      await action();
    } finally {
      _isBusy = false;
      _notify();
    }
  }

  /// HU01: takes a photo. Throws [CaptureFailure] when it fails.
  Future<CapturedImage> takePhoto() async {
    if (!_camera.isInitialized) {
      throw const CaptureFailure('La cámara aún no está lista.');
    }
    _flashShutter();
    try {
      final photo = await _camera.capture();
      return await _toCapturedImage(photo, ImageOrigin.camera);
    } on CameraException {
      throw const CaptureFailure(
        'No se pudo tomar la foto. Inténtelo de nuevo.',
      );
    }
  }

  /// HU02: picks an image of the gallery; null when the user cancels.
  /// Throws [CaptureFailure] when the gallery cannot be opened.
  Future<CapturedImage?> pickFromGallery() async {
    try {
      final photo = await _camera.pickFromGallery();
      if (photo == null) return null;
      return await _toCapturedImage(photo, ImageOrigin.gallery);
    } catch (_) {
      throw const CaptureFailure('No se pudo abrir la galería.');
    }
  }

  // Brief white flash and a tap, as camera apps do when taking a photo.
  void _flashShutter() {
    HapticFeedback.lightImpact();
    _showFlash = true;
    _notify();
    Future.delayed(const Duration(milliseconds: 120), () {
      _showFlash = false;
      _notify();
    });
  }

  /// Focuses and meters exposure where the user tapped the viewfinder.
  Future<void> focusAt(Offset tap, Size viewfinder) async {
    final previewSize = _camera.controller?.value.previewSize;
    // The preview size is reported in landscape; swap it for portrait.
    final point = previewSize == null
        ? Offset(tap.dx / viewfinder.width, tap.dy / viewfinder.height)
        : tapToPreviewPoint(
            tap,
            viewfinder,
            Size(previewSize.height, previewSize.width),
          );
    HapticFeedback.selectionClick();
    _focusPosition = tap;
    _focusTaps++;
    _notify();
    try {
      await _camera.focusAt(point);
    } on CameraException {
      // Some cameras reject focus points; the autofocus keeps working.
    }
  }

  /// Deletes a camera photo once it is no longer needed. Gallery images
  /// belong to the user and are never deleted.
  Future<void> discard(CapturedImage image) async {
    if (image.origin != ImageOrigin.camera) return;
    try {
      await File(image.path).delete();
    } on FileSystemException {
      // Already removed; nothing to do.
    }
  }

  Future<CapturedImage> _toCapturedImage(XFile file, ImageOrigin origin) async {
    final resolution = await _camera.readResolution(file.path);
    return CapturedImage(
      path: file.path,
      origin: origin,
      width: resolution.width,
      height: resolution.height,
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopWatchingMotion();
    _camera.dispose();
    super.dispose();
  }
}
