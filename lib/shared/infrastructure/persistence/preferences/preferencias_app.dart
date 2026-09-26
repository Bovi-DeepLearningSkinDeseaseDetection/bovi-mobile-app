import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales

class PreferenciasApp {
  static const _claveAyudaVista = 'ayuda_encuadre_vista';

  Future<bool> ayudaEncuadreVista() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveAyudaVista) ?? false;
  }

  Future<void> marcarAyudaEncuadreVista() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveAyudaVista, true);
  }
}