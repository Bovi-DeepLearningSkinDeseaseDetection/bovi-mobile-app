import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/infrastructure/camera/native_camera_manager.dart';
import '../../../../shared/infrastructure/network/connectivity_monitor.dart';
import '../../../../shared/infrastructure/persistence/preferences/preferences_app.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/connection_status_chip.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../widgets/guide_frame.dart';
import '../widgets/help_frame.dart';
import '../widgets/low_resolution_dialog.dart';
import 'image_preview_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {
  static const _permissionErrorCodes = {
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };

  final _camera = NativeCameraManager();
  final _preferences = ApplicationPreferences();
  late final Stream<bool> _connection = ConnectivityMonitor().watch();
  bool _isLoading = true;
  bool _isInitializing = false;
  bool _isBusy = false;
  bool _permissionDenied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showHelpOnFirstLaunch(),
    );
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;
    setState(() {
      _isLoading = true;
      _error = null;
      _permissionDenied = false;
    });
    try {
      await _camera.initialize();
    } on CameraException catch (error) {
      if (_permissionErrorCodes.contains(error.code)) {
        _permissionDenied = true;
        _error =
            'Bovi necesita acceso a la cámara para fotografiar la lesión '
            'del animal. Puede concederlo desde los ajustes del teléfono.';
      } else {
        _error = 'No se pudo iniciar la cámara.';
      }
    } finally {
      _isInitializing = false;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _showHelpOnFirstLaunch() async {
    if (await _preferences.hasSeenHelpFrame()) return;
    if (!mounted) return;
    await showFramingHelp(context);
    await _preferences.markHelpFrameAsSeen();
  }

  // Release the camera when the app is paused and reinitialize it on resume.
  // The permission prompt also pauses the app, so skip while initializing.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (!_camera.isInitialized) return;
      _camera.dispose();
      if (mounted) setState(() => _isLoading = true);
    } else if (state == AppLifecycleState.resumed) {
      if (!_camera.isInitialized) _initializeCamera();
    }
  }

  // HU01: capture an image with the camera.
  Future<void> _captureImage() async {
    if (_isBusy || !_camera.isInitialized) return;
    setState(() => _isBusy = true);
    try {
      final photo = await _camera.capture();
      final image = await _toCapturedImage(photo, ImageOrigin.camera);
      if (!mounted) return;
      await _openPreview(image);
    } on CameraException {
      _showMessage('No se pudo tomar la foto. Inténtelo de nuevo.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // HU02: select an image from the gallery.
  Future<void> _selectFromGallery() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final photo = await _camera.pickFromGallery();
      if (photo == null || !mounted) return; // The user canceled.
      final image = await _toCapturedImage(photo, ImageOrigin.gallery);
      if (!mounted) return;
      if (!image.meetsMinimumResolution) {
        final choice = await showLowResolutionDialog(context);
        if (choice == LowResolutionChoice.chooseAnother && mounted) {
          setState(() => _isBusy = false);
          await _selectFromGallery();
        }
        return;
      }
      await _openPreview(image);
    } catch (_) {
      _showMessage('No se pudo abrir la galería.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
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

  Future<void> _openPreview(CapturedImage image) async {
    final decision = await Navigator.of(context).push<PreviewDecision>(
      MaterialPageRoute(builder: (_) => ImagePreviewPage(image: image)),
    );
    if (!mounted) return;
    switch (decision) {
      case PreviewDecision.analyze:
        // The photo passed HU04 and HU05; HU06 will show the result instead.
        _showMessage('La foto está lista para el análisis.');
      case PreviewDecision.retake:
        if (image.origin == ImageOrigin.camera) {
          await _discard(image);
        } else {
          setState(() => _isBusy = false);
          await _selectFromGallery();
        }
      case null:
        if (image.origin == ImageOrigin.camera) await _discard(image);
    }
  }

  // Camera photos are temporary files; gallery images belong to the user.
  Future<void> _discard(CapturedImage image) async {
    try {
      await File(image.path).delete();
    } on FileSystemException {
      // Already removed; nothing to do.
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Cómo tomar la foto',
            onPressed: () => showFramingHelp(context),
          ),
          StreamBuilder<bool>(
            stream: _connection,
            initialData: false,
            builder: (context, snapshot) =>
                ConnectionStatusChip(isOnline: snapshot.data ?? false),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _viewfinder()),
          _CaptureControls(
            isBusy: _isBusy,
            onGallery: _selectFromGallery,
            onCapture: _captureImage,
            onHistory: () =>
                _showMessage('El historial estará disponible próximamente.'),
          ),
        ],
      ),
    );
  }

  Widget _viewfinder() {
    if (_error != null) {
      return _CameraErrorView(
        message: _error!,
        showSettings: _permissionDenied,
        onRetry: _initializeCamera,
      );
    }
    final controller = _camera.controller;
    if (_isLoading || controller == null || !_camera.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _CoverCameraPreview(controller: controller),
        ColoredBox(color: Colors.black.withValues(alpha: 0.15)),
        const IgnorePointer(child: GuideFrame()),
      ],
    );
  }
}

/// Fills the viewfinder with the camera preview, cropping the edges.
class _CoverCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _CoverCameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return Center(child: CameraPreview(controller));
    // The preview size is reported in landscape; swap it for portrait.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  final String message;
  final bool showSettings;
  final VoidCallback onRetry;

  const _CameraErrorView({
    required this.message,
    required this.showSettings,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showSettings
                  ? Icons.no_photography_outlined
                  : Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (showSettings) ...[
              ElevatedButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Abrir ajustes'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureControls extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onGallery;
  final VoidCallback onCapture;
  final VoidCallback onHistory;

  const _CaptureControls({
    required this.isBusy,
    required this.onGallery,
    required this.onCapture,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SecondaryAction(
                icon: Icons.image_outlined,
                label: 'Galería',
                onTap: onGallery,
              ),
              _CaptureButton(isBusy: isBusy, onTap: onCapture),
              _SecondaryAction(
                icon: Icons.schedule,
                label: 'Historial',
                onTap: onHistory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onTap;

  const _CaptureButton({required this.isBusy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capturar',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkGreen,
            border: Border.all(color: AppColors.softGray, width: 4),
          ),
          child: isBusy
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 3,
                  ),
                )
              : Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.4),
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryText),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
