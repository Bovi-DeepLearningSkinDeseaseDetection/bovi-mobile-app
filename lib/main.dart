import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'iam/application/internal/commandservices/auth_command_service.dart';
import 'iam/interfaces/ui/pages/auth_gate.dart';
import 'iam/interfaces/ui/viewmodels/session_view_model.dart';
import 'shared/infrastructure/di/service_locator.dart';
import 'shared/interfaces/ui/theme/app_theme.dart';
import 'shared/interfaces/ui/pages/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the local database (Isar) before the first screen.
  await setUpServices();
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
        home: const AuthGate(child: HomeShell()),
      ),
    );
  }
}
