import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../infrastructure/catalog/disease_sheet_catalog.dart';
import '../viewmodels/history_view_model.dart';
import '../widgets/history/empty_history.dart';
import '../widgets/history/evaluation_card.dart';
import '../widgets/history/history_filter_sheet.dart';
import '../widgets/history/history_list_header.dart';
import 'result_page.dart';

/// Evaluations saved on the device, newest first, with filters (HU11). The
/// state lives in [HistoryViewModel].
class HistoryPage extends StatelessWidget {
  final VoidCallback onScan;

  /// Source of the evaluations. Without it, the registered one is used.
  final EvaluationRepository? repository;

  /// Animal search for the animal filter. Without it, the registered one.
  final LivestockContextFacade? livestock;

  const HistoryPage({
    super.key,
    required this.onScan,
    this.repository,
    this.livestock,
  });

  static T? _registered<T extends Object>() =>
      locator.isRegistered<T>() ? locator<T>() : null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          HistoryViewModel(repository ?? _registered<EvaluationRepository>()),
      child: _HistoryView(
        onScan: onScan,
        livestock: livestock ?? _registered<LivestockContextFacade>(),
        sheets: _registered<DiseaseSheetCatalog>(),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final VoidCallback onScan;
  final LivestockContextFacade? livestock;
  final DiseaseSheetCatalog? sheets;

  const _HistoryView({
    required this.onScan,
    required this.livestock,
    required this.sheets,
  });

  // HU11, scenario 3: the full image and every datum of the result.
  void _open(BuildContext context, Evaluation evaluation) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ResultPage(
          image: CapturedImage(
            path: evaluation.imagePath,
            origin: evaluation.origin,
            width: 0,
            height: 0,
          ),
          result: evaluation.result,
          evaluation: evaluation,
          codes: evaluation.clinicalCodes,
          sheet: sheets?.sheetFor(evaluation.result),
        ),
      ),
    );
  }

  Future<void> _editFilters(
    BuildContext context,
    HistoryViewModel model,
  ) async {
    final filter = await showHistoryFilters(
      context,
      filter: model.filter,
      livestock: livestock,
    );
    if (filter != null) model.filter = filter;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HistoryViewModel>();
    final active = model.filter.activeCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Filtrar',
            onPressed: () => _editFilters(context, model),
            icon: Badge(
              isLabelVisible: active > 0,
              label: Text('$active'),
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _body(context, model),
    );
  }

  Widget _body(BuildContext context, HistoryViewModel model) {
    final evaluations = model.evaluations;
    if (evaluations == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.isEmptyHistory) return EmptyHistory(onScan: onScan);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: evaluations.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return HistoryListHeader(model: model, count: evaluations.length);
        }
        final evaluation = evaluations[index - 1];
        return EvaluationCard(
          evaluation: evaluation,
          onTap: () => _open(context, evaluation),
        );
      },
    );
  }
}
