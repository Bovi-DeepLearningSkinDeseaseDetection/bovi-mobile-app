import 'package:flutter/material.dart';
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
    return MaterialApp(
      title: 'Bovi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const HomeShell(),
    );
  }
}
