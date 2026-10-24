import 'package:bov_mobile_app/clinical/domain/model/aggregates/evaluation.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/evaluation_outcome.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/domain/repositories/evaluation_repository.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/history_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/result_page.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

InferenceResult _result(List<double> scores) => InferenceResult.fromScores(
  labels: const ['dermatofitosis', 'piel_sana'],
  scores: scores,
  modelVersion: 'test',
  elapsed: Duration.zero,
);

Evaluation _evaluation(String uuid, List<double> scores, DateTime date) =>
    Evaluation(
      uuid: uuid,
      createdAt: date,
      imagePath: 'missing.jpg',
      thumbnailPath: 'missing_thumb.jpg',
      origin: ImageOrigin.camera,
      result: _result(scores),
    );

/// Repository kept in memory, newest first like the Isar one.
class _MemoryRepository implements EvaluationRepository {
  final List<Evaluation> items;

  _MemoryRepository(this.items);

  @override
  Future<Evaluation> save(Evaluation evaluation) async {
    items.add(evaluation);
    return evaluation;
  }

  @override
  Stream<List<Evaluation>> watchAll() => Stream.value(
    [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );
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

  // HU11, scenario 4.
  testWidgets('an empty history invites to make the first evaluation', (
    tester,
  ) async {
    await _show(tester, []);
    expect(find.text(HistoryPage.emptyTitle), findsOneWidget);
    expect(find.text('Escanear ahora'), findsOneWidget);
  });

  // HU11, scenario 1, and HU10: inconclusive results are listed too.
  testWidgets('saved evaluations are listed newest first with their status', (
    tester,
  ) async {
    await _show(tester, [
      _evaluation('a', [0.1, 0.9], DateTime(2026, 10, 20, 9)),
      _evaluation('b', [0.55, 0.45], DateTime(2026, 10, 24, 11)),
    ]);

    final inconclusive = find.text(ResultPage.inconclusiveTitle);
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
    expect(find.text(ResultPage.retakeLabel), findsNothing);
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
}
