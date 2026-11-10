import 'package:flutter/material.dart';

import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../../shared/interfaces/ui/formatters/date_formatters.dart';
import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/queries/evaluation_filter.dart';
import '../../../../infrastructure/catalog/lesion_class_catalog.dart';
import '../../viewmodels/history_view_model.dart';

/// Search bar, chips of the active filters and number of results (HU11).
class HistoryListHeader extends StatelessWidget {
  static const searchHint = 'Buscar animal o diagnóstico';
  static const noMatchesText = 'Ninguna evaluación coincide con los filtros.';

  final HistoryViewModel model;
  final int count;

  const HistoryListHeader({
    super.key,
    required this.model,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final chips = _activeFilterChips(model.filter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          hintText: searchHint,
          leading: const Icon(
            Icons.search_rounded,
            color: AppColors.secondaryText,
          ),
          onChanged: (value) => model.query = value,
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
        const SizedBox(height: 12),
        Text(
          count == 0
              ? noMatchesText
              : '$count ${count == 1 ? 'evaluación' : 'evaluaciones'}',
          style: TextTheme.of(context).bodySmall,
        ),
      ],
    );
  }

  // One chip per active filter; its × removes only that filter.
  List<Widget> _activeFilterChips(EvaluationFilter filter) => [
    if (filter.label != null)
      _chip(
        LesionClassCatalog.displayName(filter.label!),
        () => model.filter = filter.without(diagnosis: true),
      ),
    if (filter.inconclusive)
      _chip(
        'No concluyente',
        () => model.filter = filter.without(diagnosis: true),
      ),
    if (filter.animalId != null)
      _chip(
        'Arete ${filter.animalEarTag}',
        () => model.filter = filter.without(animal: true),
      ),
    if (filter.from != null)
      _chip(
        '${DateFormatters.day(filter.from!)} – '
        '${DateFormatters.day(filter.to ?? filter.from!)}',
        () => model.filter = filter.without(dates: true),
      ),
    if (filter.syncStatus != null)
      _chip(
        filter.syncStatus == SyncStatus.synced ? 'Sincronizada' : 'Pendiente',
        () => model.filter = filter.without(sync: true),
      ),
  ];

  Widget _chip(String text, VoidCallback onDeleted) => InputChip(
    label: Text(text),
    onDeleted: onDeleted,
    deleteIcon: const Icon(Icons.close_rounded, size: 18),
  );
}
