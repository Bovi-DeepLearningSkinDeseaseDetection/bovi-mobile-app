import 'package:flutter/material.dart';

import '../../../../shared/infrastructure/di/service_locator.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../shared/interfaces/ui/widgets/icon_bubble.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../infrastructure/catalog/lesion_class_catalog.dart';
import '../widgets/evaluation_card.dart';
import 'result_page.dart';

/// Evaluations saved on the device, newest first (HU11).
class HistoryPage extends StatefulWidget {
  static const searchHint = 'Buscar animal o diagnóstico';
  static const emptyTitle = 'Aún no tiene evaluaciones';
  static const emptyMessage =
      'Los análisis que realice se guardan aquí automáticamente, '
      'aunque no tenga internet.';
  static const noMatchesText = 'Ninguna evaluación coincide con la búsqueda.';

  final VoidCallback onScan;

  /// Source of the evaluations. Without it, the registered one is used.
  final EvaluationRepository? repository;

  const HistoryPage({super.key, required this.onScan, this.repository});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final Stream<List<Evaluation>> _evaluations =
      _repository?.watchAll() ?? Stream.value(const []);
  String _query = '';

  EvaluationRepository? get _repository =>
      widget.repository ??
      (locator.isRegistered<EvaluationRepository>()
          ? locator<EvaluationRepository>()
          : null);

  // Matches the result headline, the class name or the ear tag.
  bool _matches(Evaluation evaluation) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final texts = [
      EvaluationCard.titleOf(evaluation),
      LesionClassCatalog.displayName(evaluation.result.top.label),
      evaluation.animalEarTag ?? '',
    ];
    return texts.any((text) => text.toLowerCase().contains(query));
  }

  void _open(Evaluation evaluation) {
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
          evaluatedAt: evaluation.createdAt,
          codes: evaluation.clinicalCodes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: StreamBuilder<List<Evaluation>>(
        stream: _evaluations,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          if (all.isEmpty) return _EmptyHistory(onScan: widget.onScan);
          final shown = all.where(_matches).toList();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: shown.length + 1,
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? 20 : 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SearchBar(
                      hintText: HistoryPage.searchHint,
                      leading: const Icon(
                        Icons.search_rounded,
                        color: AppColors.secondaryText,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shown.isEmpty
                          ? HistoryPage.noMatchesText
                          : '${shown.length} '
                                '${shown.length == 1 ? 'evaluación' : 'evaluaciones'}',
                      style: TextTheme.of(context).bodySmall,
                    ),
                  ],
                );
              }
              final evaluation = shown[index - 1];
              return EvaluationCard(
                evaluation: evaluation,
                onTap: () => _open(evaluation),
              );
            },
          );
        },
      ),
    );
  }
}

/// HU11, scenario 4: no evaluations yet.
class _EmptyHistory extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyHistory({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
      children: [
        const Center(
          child: IconBubble(icon: Icon(Icons.article_outlined), size: 96),
        ),
        const SizedBox(height: 20),
        Text(
          HistoryPage.emptyTitle,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          HistoryPage.emptyMessage,
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
    );
  }
}
