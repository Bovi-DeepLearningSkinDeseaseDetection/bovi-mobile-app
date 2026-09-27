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

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery);
  }
}
