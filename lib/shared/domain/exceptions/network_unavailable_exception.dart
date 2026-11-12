/// The backend could not be reached: no internet, or it did not answer.
/// The data stays on the phone and the action can be retried later.
class NetworkUnavailableException implements Exception {
  static const message =
      'No hay conexión con el servidor. Revise su internet e intente de nuevo.';

  const NetworkUnavailableException();

  @override
  String toString() => 'NetworkUnavailableException';
}
