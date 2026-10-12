import 'package:flutter/material.dart';

import '../../../../clinical/interfaces/ui/pages/capture_page.dart';
import '../../../../clinical/interfaces/ui/pages/history_page.dart';
import '../../../../iam/interfaces/ui/pages/profile_page.dart';
import '../theme/app_colors.dart';
import 'home_page.dart';

/// Sections of the mobile navigation bar.
enum AppTab {
  home('Inicio', Icons.home_outlined, Icons.home_rounded),
  scan('Escanear', Icons.photo_camera_outlined, Icons.photo_camera_rounded),
  history('Historial', Icons.article_outlined, Icons.article_rounded),
  profile('Perfil', Icons.person_outline_rounded, Icons.person_rounded);

  const AppTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Main layout of the app: the current section and the navigation bar.
///
/// The scan section has its own navigator, so the preview and the result
/// keep the navigation bar. Each section is built only while it is shown,
/// which releases the camera as soon as the user leaves the scan section.
class HomeShell extends StatefulWidget {
  final AppTab initialTab;

  const HomeShell({super.key, this.initialTab = AppTab.home});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late AppTab _tab = widget.initialTab;
  final _scanNavigator = GlobalKey<NavigatorState>();

  void _select(AppTab tab) {
    if (tab != _tab) setState(() => _tab = tab);
  }

  // Back goes through the scan screens first, then to the start screen.
  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;
    final scan = _scanNavigator.currentState;
    if (_tab == AppTab.scan && scan != null && scan.canPop()) {
      scan.maybePop();
    } else {
      _select(AppTab.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _tab == AppTab.home,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        body: TweenAnimationBuilder<double>(
          key: ValueKey(_tab),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: _page(_tab),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: const Border(top: BorderSide(color: AppColors.softGray)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _tab.index,
            onDestinationSelected: (index) => _select(AppTab.values[index]),
            destinations: [
              for (final tab in AppTab.values)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return HomePage(
          onScan: () => _select(AppTab.scan),
          onHistory: () => _select(AppTab.history),
        );
      case AppTab.scan:
        return Navigator(
          key: _scanNavigator,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                CapturePage(onHistory: () => _select(AppTab.history)),
          ),
        );
      case AppTab.history:
        return HistoryPage(onScan: () => _select(AppTab.scan));
      case AppTab.profile:
        return const ProfilePage();
    }
  }
}
