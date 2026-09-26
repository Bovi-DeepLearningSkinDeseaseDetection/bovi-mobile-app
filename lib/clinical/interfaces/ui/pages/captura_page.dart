import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../shared/infrastructure/camera/native_camera_manager.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/valueobjects/origen_imagen.dart';
import '../../../../shared/infrastructure/persistence/preferences/preferencias_app.dart';
import '../widgets/ayuda_encuadre.dart';
import '../widgets/marco_guia.dart';

class CapturaPage extends StatefulWidget {
  const CapturaPage({super.key});

  @override
  State<CapturaPage> createState() => _CapturaPageState();
}

class _CapturaPageState extends State<CapturaPage> with WidgetsBindingObserver {
  final _camara = NativeCameraManager();
  final _preferencias = PreferenciasApp();
  bool _cargando = true;
  bool _ocupado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciarCamara();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _mostrarAyudaSiEsPrimeraVez());
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
          ? 'Se necesita permiso de la cámara para capturar la lesión.'
          : 'No se pudo iniciar la cámara.';
    }
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _mostrarAyudaSiEsPrimeraVez() async {
    if (await _preferencias.ayudaEncuadreVista()) return;
    if (!mounted) return;
    await mostrarAyudaEncuadre(context);
    await _preferencias.marcarAyudaEncuadreVista();
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

  // HU01 — captura con la cámara
  Future<void> _capturar() async {
    if (_ocupado || !_camara.isInitialized) return;
    setState(() => _ocupado = true);
    try {
      final foto = await _camara.capture();
      if (!mounted) return;
      await _abrirVistaPrevia(foto.path, OrigenImagen.camara);
    } on CameraException {
      _mostrarError('No se pudo capturar la imagen.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  // HU02 — selección desde la galería
  Future<void> _seleccionarDeGaleria() async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final foto = await _camara.pickFromGallery();
      if (foto == null || !mounted) return; // el usuario canceló
      await _abrirVistaPrevia(foto.path, OrigenImagen.galeria);
    } catch (_) {
      _mostrarError('No se pudo abrir la galería.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirVistaPrevia(String ruta, OrigenImagen origen) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VistaPrevia(ruta: ruta, origen: origen),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
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
      appBar: AppBar(
        title: const Text('Bovi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Cómo tomar la foto',
            onPressed: () => mostrarAyudaEncuadre(context),
          ),
        ],
      ),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: CameraPreview(_camara.controller!)),
        const IgnorePointer(child: MarcoGuia()),
      ],
    );
  }

  Widget _controles() {
    return Container(
      height: 120,
      color: AppColors.blanco,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _botonSecundario(Icons.photo_library_outlined, 'Galería',
              onTap: _seleccionarDeGaleria),
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
              child: _ocupado
                  ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: AppColors.blanco, strokeWidth: 3),
              )
                  : null,
            ),
          ),
          _botonSecundario(Icons.history, 'Historial'), // HU11
        ],
      ),
    );
  }

  Widget _botonSecundario(IconData icono, String etiqueta,
      {VoidCallback? onTap}) {
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
              Icon(icono, color: AppColors.textoPrincipal),
              const SizedBox(height: 4),
              Text(etiqueta, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla temporal para verificar la imagen. Se reemplaza por la de resultado en el Sprint 2.
class _VistaPrevia extends StatelessWidget {
  final String ruta;
  final OrigenImagen origen;
  const _VistaPrevia({required this.ruta, required this.origen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista previa · ${origen.etiqueta}')),
      body: Center(child: Image.file(File(ruta), fit: BoxFit.contain)),
    );
  }
}