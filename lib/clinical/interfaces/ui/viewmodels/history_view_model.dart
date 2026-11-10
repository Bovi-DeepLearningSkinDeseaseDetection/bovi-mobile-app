import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/queries/evaluation_filter.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../infrastructure/catalog/lesion_class_catalog.dart';
import '../widgets/history/evaluation_card.dart';

/// State of the history screen (HU11): the filters, the search text and the
/// evaluations that meet them.
class HistoryViewModel extends ChangeNotifier {
  final EvaluationRepository? _repository;
  StreamSubscription<List<Evaluation>>? _subscription;

  EvaluationFilter _filter = EvaluationFilter.none;
  String _query = '';
  List<Evaluation>? _evaluations;

  HistoryViewModel(this._repository) {
    _listen();
  }

  EvaluationFilter get filter => _filter;
  String get query => _query;

  /// Null while the first results load.
  List<Evaluation>? get evaluations => _evaluations?.where(_matches).toList();

  /// Nothing saved yet: no filter or search can explain an empty list.
  bool get isEmptyHistory =>
      _evaluations != null &&
      _evaluations!.isEmpty &&
      _filter.isEmpty &&
      _query.trim().isEmpty;

  set filter(EvaluationFilter filter) {
    _filter = filter;
    _listen();
  }

  set query(String query) {
    _query = query;
    notifyListeners();
  }

  // The filters run in the database; the free text runs on the results.
  void _listen() {
    _subscription?.cancel();
    final repository = _repository;
    if (repository == null) {
      _evaluations = const [];
      notifyListeners();
      return;
    }
    _subscription = repository.watch(_filter).listen((evaluations) {
      _evaluations = evaluations;
      notifyListeners();
    });
  }

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
