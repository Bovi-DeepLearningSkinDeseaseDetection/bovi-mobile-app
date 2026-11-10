import 'package:flutter/material.dart';

import '../../../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../../../../../livestock/interfaces/ui/widgets/animal_picker_sheet.dart';
import '../../../../../shared/domain/model/sync_status.dart';
import '../../../../../shared/interfaces/ui/formatters/date_formatters.dart';
import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/queries/evaluation_filter.dart';
import '../../../../infrastructure/catalog/lesion_class_catalog.dart';
import 'filter_field.dart';

/// Filters of the history: animal, disease, date range and synchronization
/// (HU11, scenario 2). Returns the new filter, or null when dismissed.
Future<EvaluationFilter?> showHistoryFilters(
  BuildContext context, {
  required EvaluationFilter filter,
  LivestockContextFacade? livestock,
}) {
  return showModalBottomSheet<EvaluationFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    builder: (context) =>
        _HistoryFilters(initial: filter, livestock: livestock),
  );
}

class _HistoryFilters extends StatefulWidget {
  final EvaluationFilter initial;
  final LivestockContextFacade? livestock;

  const _HistoryFilters({required this.initial, required this.livestock});

  @override
  State<_HistoryFilters> createState() => _HistoryFiltersState();
}

class _HistoryFiltersState extends State<_HistoryFilters> {
  late int? _animalId = widget.initial.animalId;
  late String? _animalEarTag = widget.initial.animalEarTag;
  late String? _label = widget.initial.label;
  late bool _inconclusive = widget.initial.inconclusive;
  late DateTime? _from = widget.initial.from;
  late DateTime? _to = widget.initial.to;
  late SyncStatus? _syncStatus = widget.initial.syncStatus;

  EvaluationFilter get _filter => EvaluationFilter(
    animalId: _animalId,
    animalEarTag: _animalEarTag,
    label: _label,
    inconclusive: _inconclusive,
    from: _from,
    to: _to,
    syncStatus: _syncStatus,
  );

  Future<void> _pickAnimal() async {
    final animal = await showAnimalPicker(context, widget.livestock!);
    if (animal == null) return;
    setState(() {
      _animalId = animal.id;
      _animalEarTag = animal.earTag;
    });
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _from == null
          ? null
          : DateTimeRange(start: _from!, end: _to ?? now),
      helpText: 'Rango de fechas',
    );
    if (range == null) return;
    setState(() {
      _from = range.start;
      _to = range.end;
    });
  }

  void _setDiagnosis({String? label, bool inconclusive = false}) =>
      setState(() {
        _label = label;
        _inconclusive = inconclusive;
      });

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filtrar historial', style: textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text('Resultado', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _label == null && !_inconclusive,
                onSelected: (_) => _setDiagnosis(),
              ),
              for (final label in LesionClassCatalog.labels)
                ChoiceChip(
                  label: Text(LesionClassCatalog.displayName(label)),
                  selected: _label == label,
                  onSelected: (_) => _setDiagnosis(label: label),
                ),
              ChoiceChip(
                label: const Text('No concluyente'),
                selected: _inconclusive,
                onSelected: (_) => _setDiagnosis(inconclusive: true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Animal', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          FilterField(
            icon: Icons.sell_outlined,
            text: _animalEarTag == null
                ? 'Todos los animales'
                : 'Arete $_animalEarTag',
            onTap: widget.livestock == null ? null : _pickAnimal,
            onClear: _animalId == null
                ? null
                : () => setState(() {
                    _animalId = null;
                    _animalEarTag = null;
                  }),
          ),
          const SizedBox(height: 20),
          Text('Fechas', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          FilterField(
            icon: Icons.date_range_outlined,
            text: _from == null
                ? 'Todas las fechas'
                : '${DateFormatters.day(_from!)} – ${DateFormatters.day(_to ?? _from!)}',
            onTap: _pickDates,
            onClear: _from == null
                ? null
                : () => setState(() {
                    _from = null;
                    _to = null;
                  }),
          ),
          const SizedBox(height: 20),
          Text('Sincronización', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<SyncStatus?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Todas')),
              ButtonSegment(
                value: SyncStatus.pending,
                label: Text('Pendiente'),
              ),
              ButtonSegment(
                value: SyncStatus.synced,
                label: Text('Sincronizada'),
              ),
            ],
            selected: {_syncStatus},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _syncStatus = selection.first),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(EvaluationFilter.none),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_filter),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
