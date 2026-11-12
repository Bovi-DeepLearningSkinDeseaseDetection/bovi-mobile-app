import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/formatters/date_formatters.dart';
import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/clinical_code.dart';
import '../../../domain/model/value_objects/disease_sheet.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../widgets/result/evaluation_animal_section.dart';
import '../widgets/result/clinical_codes_card.dart';
import '../widgets/result/disclaimer_notice.dart';
import '../widgets/result/probabilities_card.dart';
import '../widgets/result/result_photo.dart';
import '../widgets/result/result_texts.dart';
import '../widgets/result/result_verdict.dart';
import '../widgets/result/save_status.dart';
import 'disease_sheet_page.dart';

/// Shows the preliminary result of the analysis (HU07, HU08, HU09), or a
/// saved evaluation of the history (HU11, scenario 3).
class ResultPage extends StatelessWidget {
  final CapturedImage image;
  final InferenceResult result;

  /// Automatic save of a new analysis (HU10); it completes with the saved
  /// evaluation, or null when it could not be saved.
  final Future<Evaluation?>? saving;

  /// An evaluation of the history. When given, the page shows its date and
  /// no scan action.
  final Evaluation? evaluation;

  /// Standard codes of the result (HU07): MeSH and NCBI Taxonomy.
  final List<ClinicalCode> codes;

  /// Information sheet of the detected disease (HU09); null for healthy
  /// skin and inconclusive results.
  final DiseaseSheet? sheet;

  const ResultPage({
    super.key,
    required this.image,
    required this.result,
    this.saving,
    this.evaluation,
    this.codes = const [],
    this.sheet,
  });

  void _openSheet(BuildContext context, DiseaseSheet sheet) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => DiseaseSheetPage(sheet: sheet)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromHistory = evaluation != null;
    // HU08: an inconclusive result shows only the two most probable classes.
    final classes = result.isConclusive
        ? result.ranked
        : result.ranked.take(2).toList();
    final smallText = TextTheme.of(context).bodySmall;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fromHistory ? ResultTexts.historyTitle : ResultTexts.pageTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ResultPhoto(path: image.path),
                    if (fromHistory) ...[
                      const SizedBox(height: 12),
                      Text(
                        DateFormatters.dayAndTime(evaluation!.createdAt),
                        style: smallText,
                      ),
                      // HU12: why the backend refused it.
                      if (evaluation!.syncError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'No se pudo respaldar: ${evaluation!.syncError}',
                          style: smallText?.copyWith(
                            color: AppColors.lesionText,
                          ),
                        ),
                      ],
                    ],
                    if (saving != null) ...[
                      const SizedBox(height: 12),
                      SaveStatus(saving: saving!),
                    ],
                    const SizedBox(height: 20),
                    ResultVerdict(
                      result: result,
                      onMore: sheet == null
                          ? null
                          : () => _openSheet(context, sheet!),
                    ),
                    if (codes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ClinicalCodesCard(codes: codes),
                    ],
                    if (EvaluationAnimalSection.isAvailable &&
                        (fromHistory || saving != null)) ...[
                      const SizedBox(height: 16),
                      _AnimalSection(saving: saving, evaluation: evaluation),
                    ],
                    const SizedBox(height: 20),
                    ProbabilitiesCard(classes: classes),
                    const SizedBox(height: 16),
                    const DisclaimerNotice(),
                    const SizedBox(height: 12),
                    Text(
                      'Modelo ${result.modelVersion} · '
                      '${result.elapsed.inMilliseconds} ms · '
                      'Origen: ${image.origin.label}',
                      style: smallText,
                    ),
                  ],
                ),
              ),
            ),
            if (!fromHistory)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: Text(
                    result.isConclusive
                        ? ResultTexts.retakeLabel
                        : ResultTexts.inconclusiveRetakeLabel,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// HU15: the evaluation can be linked to an animal once it is saved.
class _AnimalSection extends StatelessWidget {
  final Future<Evaluation?>? saving;
  final Evaluation? evaluation;

  const _AnimalSection({required this.saving, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Evaluation?>(
      future: saving ?? Future.value(evaluation),
      initialData: evaluation,
      builder: (context, snapshot) =>
          EvaluationAnimalSection(evaluation: snapshot.data),
    );
  }
}
