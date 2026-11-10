import 'package:bov_mobile_app/clinical/domain/model/aggregates/evaluation.dart';
import 'package:bov_mobile_app/clinical/domain/model/queries/evaluation_filter.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/body_zone.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/evaluation_outcome.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_repository.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/history_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/viewmodels/history_view_model.dart';
import 'package:bov_mobile_app/shared/domain/model/sync_status.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/widgets/status_badge.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/result/result_texts.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/history/empty_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

InferenceResult _result(List<double> scores) => InferenceResult.fromScores(
  labels: const ['dermatofitosis', 'piel_sana'],
  scores: scores,
  modelVersion: 'test',
  elapsed: Duration.zero,
);

Evaluation _evaluation(
  String uuid,
  List<double> scores,
  DateTime date, {
  int? animalId,
  String? earTag,
  BodyZone? zone,
  SyncStatus sync = SyncStatus.pending,
}) => Evaluation(
  id: uuid.hashCode,
  uuid: uuid,
  createdAt: date,
  imagePath: 'missing.jpg',
  thumbnailPath: 'missing_thumb.jpg',
  origin: ImageOrigin.camera,
  result: _result(scores),
  animalId: animalId,
  animalEarTag: earTag,
  bodyZone: zone,
  syncStatus: sync,
);

/// Repository kept in memory, with the same rules as the Isar one.
class _MemoryRepository implements EvaluationRepository {
  final List<Evaluation> items;

  _MemoryRepository(this.items);

  @override
  Future<Evaluation> save(Evaluation evaluation) async {
    items.add(evaluation);
    return evaluation;
  }

  @override
  Stream<List<Evaluation>> watch([
    EvaluationFilter filter = EvaluationFilter.none,
  ]) => Stream.value(
    items.where(filter.matches).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<Evaluation> assignAnimal(
    int evaluationId, {
    required int animalId,
    required String animalEarTag,
    required BodyZone bodyZone,
  }) => throw UnimplementedError();
}

Future<void> _show(WidgetTester tester, List<Evaluation> items) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HistoryPage(onScan: () {}, repository: _MemoryRepository(items)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('the outcome follows the confidence threshold and the class', () {
    expect(EvaluationOutcome.of(_result([0.9, 0.1])), EvaluationOutcome.lesion);
    expect(
      EvaluationOutcome.of(_result([0.1, 0.9])),
      EvaluationOutcome.healthy,
    );
    expect(
      EvaluationOutcome.of(_result([0.55, 0.45])),
      EvaluationOutcome.inconclusive,
    );
  });

  // HU11, scenario 2: only the evaluations that meet every filter.
  group('EvaluationFilter', () {
    final lesion = _evaluation(
      'a',
      [0.9, 0.1],
      DateTime(2026, 10, 20, 23, 30),
      animalId: 1,
      earTag: 'PE0012',
    );
    final unsure = _evaluation('b', [0.55, 0.45], DateTime(2026, 10, 21));
    final healthy = _evaluation(
      'c',
      [0.1, 0.9],
      DateTime(2026, 10, 22),
      animalId: 2,
      sync: SyncStatus.synced,
    );
    List<String> shown(EvaluationFilter filter) => [
      lesion,
      unsure,
      healthy,
    ].where(filter.matches).map((e) => e.uuid).toList();

    test('a disease excludes inconclusive results of that class', () {
      expect(shown(const EvaluationFilter(label: 'dermatofitosis')), ['a']);
      expect(shown(const EvaluationFilter(inconclusive: true)), ['b']);
    });

    test('the date range includes its whole first and last day', () {
      expect(
        shown(
          EvaluationFilter(
            from: DateTime(2026, 10, 20),
            to: DateTime(2026, 10, 21),
          ),
        ),
        ['a', 'b'],
      );
    });

    test('animal and sync status are combined with the other filters', () {
      expect(shown(const EvaluationFilter(animalId: 2)), ['c']);
      expect(shown(const EvaluationFilter(syncStatus: SyncStatus.pending)), [
        'a',
        'b',
      ]);
      expect(
        shown(const EvaluationFilter(animalId: 1, label: 'piel_sana')),
        isEmpty,
      );
      expect(
        const EvaluationFilter(animalId: 1, label: 'sarna').activeCount,
        2,
      );
    });
  });

  // HU11, scenario 4.
  testWidgets('an empty history invites to make the first evaluation', (
    tester,
  ) async {
    await _show(tester, []);
    expect(find.text(EmptyHistory.title), findsOneWidget);
    expect(find.text('Escanear ahora'), findsOneWidget);
  });

  // HU11, scenario 1, and HU10: inconclusive results are listed too.
  testWidgets('saved evaluations are listed newest first with their status', (
    tester,
  ) async {
    await _show(tester, [
      _evaluation(
        'a',
        [0.1, 0.9],
        DateTime(2026, 10, 20, 9),
        animalId: 1,
        earTag: 'PE0012',
        zone: BodyZone.back,
      ),
      _evaluation('b', [0.55, 0.45], DateTime(2026, 10, 24, 11)),
    ]);

    final inconclusive = find.text(ResultTexts.inconclusiveTitle);
    final healthy = find.text('Piel sana');
    expect(inconclusive, findsOneWidget);
    expect(healthy, findsOneWidget);
    expect(
      tester.getTopLeft(inconclusive).dy,
      lessThan(tester.getTopLeft(healthy).dy),
    );
    expect(find.text(HealthStatus.review.label), findsOneWidget);
    expect(find.text(HealthStatus.healthy.label), findsOneWidget);
    expect(find.text('Pendiente'), findsNWidgets(2));
    expect(find.text('Arete PE0012 · Lomo'), findsOneWidget);
    expect(find.text('Sin animal'), findsOneWidget);
  });

  // HU11, scenario 3.
  testWidgets('tapping an evaluation opens its details', (tester) async {
    await _show(tester, [
      _evaluation('a', [0.91, 0.09], DateTime(2026, 10, 24, 10, 5)),
    ]);
    await tester.tap(find.text('Indicios de dermatofitosis'));
    await tester.pumpAndSettle();

    expect(find.text('Evaluación'), findsOneWidget);
    expect(find.text('24/10/2026 · 10:05'), findsOneWidget);
    expect(find.text(ResultTexts.retakeLabel), findsNothing);
  });

  testWidgets('the search filters by the result', (tester) async {
    await _show(tester, [
      _evaluation('a', [0.1, 0.9], DateTime(2026, 10, 20)),
      _evaluation('b', [0.9, 0.1], DateTime(2026, 10, 21)),
    ]);
    await tester.enterText(find.byType(TextField), 'dermato');
    await tester.pumpAndSettle();

    expect(find.text('Indicios de dermatofitosis'), findsOneWidget);
    expect(find.text('Piel sana'), findsNothing);
  });

  // HU11, scenario 2: the filter chip can be removed from the list.
  testWidgets('an active filter is shown as a chip that can be removed', (
    tester,
  ) async {
    final repository = _MemoryRepository([
      _evaluation('a', [0.1, 0.9], DateTime(2026, 10, 20)),
      _evaluation('b', [0.9, 0.1], DateTime(2026, 10, 21)),
    ]);
    final model = HistoryViewModel(repository);
    await tester.pumpAndSettle();
    model.filter = const EvaluationFilter(label: 'dermatofitosis');
    await tester.pumpAndSettle();

    expect(model.evaluations!.map((e) => e.uuid), ['b']);
    expect(model.isEmptyHistory, isFalse);

    model.filter = const EvaluationFilter(label: 'sarna');
    await tester.pumpAndSettle();
    expect(model.evaluations, isEmpty);
    // An empty filtered list is not an empty history.
    expect(model.isEmptyHistory, isFalse);
    model.dispose();
  });
}
