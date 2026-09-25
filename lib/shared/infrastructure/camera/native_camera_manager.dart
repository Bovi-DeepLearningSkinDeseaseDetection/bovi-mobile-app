import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

/// Gestion de accso a la camara

class NativeCameraManager {
  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async{
    final camaras = await availableCameras();
    if(camaras.isEmpty){
      throw CameraException('no_camera', 'No see encontró una cámara disponible');
    }
    final trasera = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
    );
    _controller = CameraController(
      trasera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  Future<XFile> capture() async{
    if (!isInitialized) throw StateError('La cámara no está inicializada');
    return _controller!.takePicture();
  }

  Future<void> dispose() async{
    await _controller?.dispose();
    _controller =  null;
  }

  Future<XFile?> pickFromGallery(){
    return _picker.pickImage(source: ImageSource.gallery);
  }
}