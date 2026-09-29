import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

/// Manages access to the device camera and image gallery.
class NativeCameraManager {
  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('no_camera', 'No camera is available.');
    }
    final rearCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    // The high preset captures at 720p, the minimum required by RF1.
    _controller = CameraController(
      rearCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  Future<XFile> capture() async {
    if (!isInitialized) throw StateError('The camera is not initialized.');
    return _controller!.takePicture();
  }

  // Clear the reference first so the preview stops using a disposed controller.
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery);
  }

  /// Reads the image dimensions from its header without decoding the pixels.
  Future<({int width, int height})> readResolution(String path) async {
    final buffer = await ui.ImmutableBuffer.fromFilePath(path);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final resolution = (width: descriptor.width, height: descriptor.height);
    descriptor.dispose();
    buffer.dispose();
    return resolution;
  }
}
