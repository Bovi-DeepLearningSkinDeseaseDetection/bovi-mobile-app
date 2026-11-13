import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'clinical/application/internal/commandservices/cloud_sync_service.dart';
import 'clinical/domain/repositories/evaluation_sync_repository.dart';
import 'clinical/interfaces/ui/viewmodels/cloud_sync_view_model.dart';
import 'clinical/interfaces/ui/widgets/restore_offer.dart';
import 'iam/application/internal/commandservices/auth_command_service.dart';
import 'iam/interfaces/ui/pages/auth_gate.dart';
import 'iam/interfaces/ui/viewmodels/session_view_model.dart';
import 'shared/infrastructure/background/background_sync.dart';
import 'shared/infrastructure/di/service_locator.dart';
import 'shared/infrastructure/network/connectivity_monitor.dart';
import 'shared/interfaces/ui/theme/app_theme.dart';
import 'shared/interfaces/ui/pages/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the local database (Isar) before the first screen.
  await setUpServices();
  // Backs up the evaluations even with the app closed (HU12).
  try {
    await scheduleBackgroundSync();
  } catch (error) {
    debugPrint('The background sync could not be scheduled: $error');
  }
  runApp(const BoviApp());
}

class BoviApp extends StatelessWidget {
  const BoviApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The session decides between the sign in and the app (HU14).
    return ChangeNotifierProvider(
      create: (_) => SessionViewModel(locator<AuthCommandService>())..load(),
      child: MaterialApp(
        title: 'Bovi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const AuthGate(child: _SignedInApp()),
      ),
    );
  }
}

/// The app of a farmer with a session, syncing on its own (HU12). Built
/// only while signed in, so nothing syncs without a session.
class _SignedInApp extends StatelessWidget {
  const _SignedInApp();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CloudSyncViewModel(
        sync: locator<CloudSyncService>().syncNow,
        connectivity: locator<ConnectivityMonitor>().watch(),
        pendingCount: locator<EvaluationSyncRepository>().watchPendingCount(),
        // The backend no longer accepts the session: back to the sign in.
        onSignedOut: context.read<SessionViewModel>().load,
      )..start(),
      // HU13: on a phone without the farmer's data, offer the restore.
      child: const RestoreOffer(child: HomeShell()),
    );
  }
}
