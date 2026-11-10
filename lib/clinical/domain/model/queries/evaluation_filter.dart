import '../../../../shared/domain/model/sync_status.dart';
import '../aggregates/evaluation.dart';
import '../value_objects/evaluation_outcome.dart';

/// Filters of the history (HU11, scenario 2). An evaluation is shown only
/// when it meets every filter that is set.
class EvaluationFilter {
  /// Animal of the evaluation and its ear tag, shown on the filter chip.
  final int? animalId;
  final String? animalEarTag;

  /// Class of the model, for example "dermatofitosis". Only conclusive
  /// results have a class.
  final String? label;

  /// Only inconclusive results.
  final bool inconclusive;

  /// First and last day, both included.
  final DateTime? from;
  final DateTime? to;

  final SyncStatus? syncStatus;

  const EvaluationFilter({
    this.animalId,
    this.animalEarTag,
    this.label,
    this.inconclusive = false,
    this.from,
    this.to,
    this.syncStatus,
  });

  static const none = EvaluationFilter();

  /// Start of the first day and end of the last day of the range.
  DateTime? get start =>
      from == null ? null : DateTime(from!.year, from!.month, from!.day);
  DateTime? get end => to == null
      ? null
      : DateTime(
          to!.year,
          to!.month,
          to!.day + 1,
        ).subtract(const Duration(microseconds: 1));

  /// Number of filters that are set, for the badge of the filter button.
  int get activeCount => [
    animalId != null,
    label != null || inconclusive,
    from != null || to != null,
    syncStatus != null,
  ].where((active) => active).length;

  bool get isEmpty => activeCount == 0;

  /// The same filter without the groups marked true.
  EvaluationFilter without({
    bool diagnosis = false,
    bool animal = false,
    bool dates = false,
    bool sync = false,
  }) => EvaluationFilter(
    label: diagnosis ? null : label,
    inconclusive: !diagnosis && inconclusive,
    animalId: animal ? null : animalId,
    animalEarTag: animal ? null : animalEarTag,
    from: dates ? null : from,
    to: dates ? null : to,
    syncStatus: sync ? null : syncStatus,
  );

  /// Same rules as the database query, for repositories kept in memory.
  bool matches(Evaluation evaluation) {
    if (animalId != null && evaluation.animalId != animalId) return false;
    final outcome = evaluation.outcome;
    if (inconclusive && outcome != EvaluationOutcome.inconclusive) {
      return false;
    }
    if (label != null &&
        (outcome == EvaluationOutcome.inconclusive ||
            evaluation.result.top.label != label)) {
      return false;
    }
    if (start != null && evaluation.createdAt.isBefore(start!)) return false;
    if (end != null && evaluation.createdAt.isAfter(end!)) return false;
    if (syncStatus != null && evaluation.syncStatus != syncStatus) {
      return false;
    }
    return true;
  }
}
