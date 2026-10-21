import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../widgets/bovi_logo.dart';
import '../widgets/farm_landscape.dart';

/// Start screen: welcome, illustration and the two main actions.
class HomePage extends StatelessWidget {
  static const welcomeText = 'Bienvenido\na Bovi';
  static const scanLabel = 'Escanear ahora';
  static const historyLabel = 'Ver historial';

  final VoidCallback onScan;
  final VoidCallback onHistory;

  const HomePage({super.key, required this.onScan, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                        child: Row(
                          children: [
                            const BoviLogo(size: 42),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                              ),
                              iconSize: 26,
                              tooltip: 'Notificaciones',
                              onPressed: () => _showNoNotifications(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Text(
                        welcomeText,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 190),
                        child: const FarmLandscape(),
                      ),
                    ),
                    _ActionsPanel(onScan: onScan, onHistory: onHistory),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoNotifications(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('No hay notificaciones nuevas.')),
      );
  }
}

/// White sheet over the hills with the primary and secondary actions.
class _ActionsPanel extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onHistory;

  const _ActionsPanel({required this.onScan, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    // The ground color shows through the rounded corners, so the sheet
    // looks laid over the front hill.
    return ColoredBox(
      color: FarmLandscape.groundColor,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.photo_camera_rounded),
              label: const Text(HomePage.scanLabel),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onHistory,
              icon: const Icon(Icons.history_rounded),
              label: const Text(HomePage.historyLabel),
            ),
          ],
        ),
      ),
    );
  }
}
