import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../../clinical/application/internal/commandservices/cloud_sync_service.dart';
import '../di/service_locator.dart';

const _taskName = 'bovi.cloudSync';
const _uniqueName = 'bovi-cloud-sync';

/// Runs in its own isolate when Android wakes the app up, even if it is
/// closed (HU12, scenario 1: "en segundo plano, sin que el ganadero haga
/// nada").
@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      await setUpServices();
      final report = await locator<CloudSyncService>().syncNow();
      // false: Android retries later with backoff (the connection dropped).
      return report.outcome != SyncOutcome.offline;
    } catch (error) {
      debugPrint('Background sync failed: $error');
      return false;
    }
  });
}

/// Every 15 minutes (the minimum of Android) and only with internet, so it
/// costs no battery while the farmer is in the farm without signal.
Future<void> scheduleBackgroundSync() async {
  if (!Platform.isAndroid) return;
  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    _uniqueName,
    _taskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 1),
  );
}
