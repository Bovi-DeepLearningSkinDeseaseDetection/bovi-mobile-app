import 'package:flutter/foundation.dart';

import '../../../application/internal/commandservices/history_restore_service.dart';

enum RestoreStage { loading, ready, running, finished }

/// State of the restore screen (HU13).
class HistoryRestoreViewModel extends ChangeNotifier {
  final HistoryRestoreService _service;

  RestoreStage _stage = RestoreStage.loading;
  int? _cloudCount;
  RestoreProgress _progress = const RestoreProgress(0, 0);
  RestoreReport? _report;

  HistoryRestoreViewModel(this._service, {int? cloudCount}) {
    if (cloudCount != null) {
      _cloudCount = cloudCount;
      _stage = RestoreStage.ready;
    } else {
      _loadCount();
    }
  }

  RestoreStage get stage => _stage;

  /// Evaluations in the cloud; null without connection.
  int? get cloudCount => _cloudCount;
  RestoreProgress get progress => _progress;
  RestoreReport? get report => _report;

  Future<void> _loadCount() async {
    _cloudCount = await _service.cloudCount();
    _stage = RestoreStage.ready;
    notifyListeners();
  }

  Future<void> restore() async {
    _stage = RestoreStage.running;
    _progress = RestoreProgress(0, _cloudCount ?? 0);
    notifyListeners();
    _report = await _service.restore(
      onProgress: (progress) {
        _progress = progress;
        notifyListeners();
      },
    );
    _stage = RestoreStage.finished;
    notifyListeners();
  }
}
