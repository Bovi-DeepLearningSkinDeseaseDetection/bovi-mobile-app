import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device has a network connection.
class ConnectivityMonitor {
  final Connectivity _connectivity;

  ConnectivityMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  /// Emits the current status and then every change.
  Stream<bool> watch() async* {
    yield _isOnline(await _connectivity.checkConnectivity());
    yield* _connectivity.onConnectivityChanged.map(_isOnline);
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
