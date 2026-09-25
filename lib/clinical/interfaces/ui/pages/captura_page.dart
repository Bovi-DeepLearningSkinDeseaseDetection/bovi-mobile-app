import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../shared/infrastructure/camera/native_camera_manager.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';

class CapturaPage extends StatefulWidget {
  const CapturaPage({super.key});

  @override
  State<CapturaPage> createState() => _CapturaPageState();
}

class _CapturaPageState extends State<CapturaPage> with WidgetsBindingObserver {
  final _camara = NativeCameraManager();
  bool _cargando = true;
  bool _capturando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciarCamara();
  }

  Future<void> _iniciarCamara() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _camara.initialize();
    } on CameraException catch (e) {
      _error = e.code == 'CameraAccessDenied'
          ? 'Se necesita peremisos de la cámara para capturar la lesión.'
          : 'No se pudo iniciar la cámara.';
    }
    if (mounted) setState(() => _cargando = false);
  }

  // Libera la cámara al salir de la app y la recupera al volver
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _camara.dispose();
      if (mounted) setState(() => _cargando = true);
    } else if (state == AppLifecycleState.resumed) {
      _iniciarCamara();
    }
  }

  Future<void> _capturar() async {
    if (_capturando || !_camara.isInitialized) return;
    setState(() => _capturando = true);
    try {
      final foto = await _camara.capture();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _VistaPrevia(ruta: foto.path)),
      );
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo capturar la imagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camara.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Bovi')),
      body: Column(
        children: [
          Expanded(child: _visor()),
          _controles(),
        ],
      ),
    );
  }

  Widget _visor() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _iniciarCamara,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (_cargando || !_camara.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(child: CameraPreview(_camara.controller!));
  }

  Widget _controles() {
    return Container(
      height: 120,
      color: AppColors.blanco,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _botonSecundario(Icons.photo_library_outlined, 'Galería'),
          GestureDetector(
            onTap: _capturar,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.verdePrincipal,
                border: Border.all(color: AppColors.grisSuave, width: 5),
              ),
              child: _capturando
                  ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: AppColors.blanco, strokeWidth: 3),
              )
                  : null,
            ),
          ),
          _botonSecundario(Icons.history, 'Historial'),
        ],
      ),
    );
  }

  Widget _botonSecundario(IconData icono, String etiqueta) {
    return Opacity(
      opacity: 0.4, // se habilitan en sus historias
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: AppColors.textoPrincipal),
          const SizedBox(height: 4),
          Text(etiqueta, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

/// Pantalla temporal para verificar la captura. Se reemplaza por la de resultado en el Sprint 2.
class _VistaPrevia extends StatelessWidget {
  final String ruta;
  const _VistaPrevia({required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista previa')),
      body: Center(child: Image.file(File(ruta), fit: BoxFit.contain)),
    );
  }
}