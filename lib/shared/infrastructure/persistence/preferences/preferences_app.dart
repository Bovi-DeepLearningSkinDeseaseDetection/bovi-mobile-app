import 'package:shared_preferences/shared_preferences.dart';

/// Stores local application preferences.
class ApplicationPreferences {
  static const _helpFrameSeenKey = 'help_frame_seen';
  static const _legacyHelpFrameSeenKey = 'ayuda_encuadre_vista';

  Future<bool> hasSeenHelpFrame() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSeenHelpFrame = preferences.getBool(_helpFrameSeenKey);
    if (hasSeenHelpFrame != null) return hasSeenHelpFrame;

    final legacyValue = preferences.getBool(_legacyHelpFrameSeenKey);
    if (legacyValue == null) return false;

    await preferences.setBool(_helpFrameSeenKey, legacyValue);
    await preferences.remove(_legacyHelpFrameSeenKey);
    return legacyValue;
  }

  Future<void> markHelpFrameAsSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_helpFrameSeenKey, true);
  }

  /// The farmer answered "Ahora no" to restoring the history (HU13): it is
  /// not offered again on this phone, but stays in the profile.
  Future<bool> hasDeclinedRestore(String farmerId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('restore_declined_$farmerId') ?? false;
  }

  Future<void> declineRestore(String farmerId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('restore_declined_$farmerId', true);
  }
}
