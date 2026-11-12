import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../application/internal/commandservices/cloud_sync_service.dart';

/// CloudSyncViewModel of the architecture (HU12): watches the connection
/// and syncs on its own, while the app is open, whenever:
/// - the phone gets a connection back (scenario 1),
/// - there are new evaluations (once their settle time passed),
/// - the app comes back to the front, or every 15 minutes.
/// With the app closed, WorkManager does the same in the background.
class CloudSyncViewModel extends ChangeNotifier {
  static const _periodic = Duration(minutes: 15);

  final Future<SyncReport> Function() _sync;
  final Stream<bool> _connectivity;
  final Stream<int> _pendingCount;
  final VoidCallback? _onSignedOut;

  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<int>? _pendingSub;
  AppLifecycleListener? _lifecycle;
  Timer? _timer;
  Timer? _settleTimer;

  bool _online = false;
  bool _syncing = false;
  int _pending = 0;
  SyncReport? _lastReport;

  CloudSyncViewModel({
    required this._sync,
    required this._connectivity,
    required this._pendingCount,
    this._onSignedOut,
  });

  bool get isOnline => _online;
  bool get isSyncing => _syncing;

  /// Evaluations waiting for the cloud.
  int get pendingCount => _pending;
  SyncReport? get lastReport => _lastReport;

  void start() {
    _connectionSub = _connectivity.listen((online) {
      final reconnected = online && !_online;
      _online = online;
      notifyListeners();
      if (reconnected) syncNow();
    });
    _pendingSub = _pendingCount.listen((count) {
      final added = count > _pending;
      _pending = count;
      notifyListeners();
      // A new evaluation can go up once the farmer had time to assign the
      // animal (CloudSyncService.settleTime).
      if (added) {
        _settleTimer?.cancel();
        _settleTimer = Timer(
          CloudSyncService.settleTime + const Duration(seconds: 5),
          syncNow,
        );
      }
    });
    _lifecycle = AppLifecycleListener(onResume: syncNow);
    _timer = Timer.periodic(_periodic, (_) => syncNow());
  }

  /// Also the "Sincronizar ahora" button. Does nothing offline.
  Future<void> syncNow() async {
    if (!_online || _syncing) return;
    _syncing = true;
    notifyListeners();
    try {
      _lastReport = await _sync();
      if (_lastReport!.outcome == SyncOutcome.signedOut) _onSignedOut?.call();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _pendingSub?.cancel();
    _lifecycle?.dispose();
    _timer?.cancel();
    _settleTimer?.cancel();
    super.dispose();
  }
}
