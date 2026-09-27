import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../shared/infrastructure/camera/native_camera_manager.dart';
import '../../../../shared/infrastructure/persistence/preferences/preferences_app.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/value_objects/origin_image.dart';
import '../widgets/guide_frame.dart';
import '../widgets/help_frame.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {
  final _camera = NativeCameraManager();
  final _preferences = ApplicationPreferences();
  bool _isLoading = true;
  bool _isBusy = false;
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _camera.initialize();
    } on CameraException catch (error) {
      _error = error.code == 'CameraAccessDenied'
          ? 'Camera permission is required to capture the lesion.'
          : 'The camera could not be started.';
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
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _camera.dispose();
      if (mounted) setState(() => _isLoading = true);
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // Feature 01: capture an image with the camera.
  Future<void> _captureImage() async {
    if (_isBusy || !_camera.isInitialized) return;
    setState(() => _isBusy = true);
    try {
      final photo = await _camera.capture();
      if (!mounted) return;
      await _openPreview(photo.path, ImageOrigin.camera);
    } on CameraException {
      _showError('The image could not be captured.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // Feature 02: select an image from the gallery.
  Future<void> _selectFromGallery() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final photo = await _camera.pickFromGallery();
      if (photo == null || !mounted) return; // The user canceled.
      await _openPreview(photo.path, ImageOrigin.gallery);
    } catch (_) {
      _showError('The gallery could not be opened.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openPreview(String path, ImageOrigin origin) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImagePreview(path: path, origin: origin),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            tooltip: 'How to take a photo',
            onPressed: () => showFramingHelp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _cameraPreview()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_isLoading || !_camera.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: CameraPreview(_camera.controller!)),
        const IgnorePointer(child: GuideFrame()),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      height: 120,
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _secondaryButton(
            Icons.photo_library_outlined,
            'Gallery',
            onTap: _selectFromGallery,
          ),
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen,
                border: Border.all(color: AppColors.softGray, width: 5),
              ),
              child: _isBusy
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : null,
            ),
          ),
          _secondaryButton(Icons.history, 'History'), // Feature 11.
        ],
      ),
    );
  }

  Widget _secondaryButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap != null ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryText),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Temporary image preview; it will be replaced by the results screen.
class _ImagePreview extends StatelessWidget {
  final String path;
  final ImageOrigin origin;

  const _ImagePreview({required this.path, required this.origin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview · ${origin.label}')),
      body: Center(child: Image.file(File(path), fit: BoxFit.contain)),
    );
  }
}
