import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';

/// Saved evaluations. They are stored from HU10 on; until then the list is
/// always empty.
class HistoryPage extends StatelessWidget {
  static const searchHint = 'Buscar animal o diagnóstico';
  static const emptyTitle = 'Aún no hay resultados guardados';
  static const emptyMessage =
      'Los análisis que guarde aparecerán aquí para revisarlos cuando quiera.';

  final VoidCallback onScan;

  const HistoryPage({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const SearchBar(
            hintText: searchHint,
            leading: Icon(Icons.search_rounded, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 48),
          const Center(
            child: IconBubble(icon: Icon(Icons.article_outlined), size: 96),
          ),
          const SizedBox(height: 20),
          Text(
            emptyTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.bodyText),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Escanear ahora'),
          ),
        ],
      ),
    );
  }
}
