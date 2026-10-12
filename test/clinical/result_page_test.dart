import 'package:bov_mobile_app/clinical/domain/model/value_objects/captured_image.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/result_page.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _image = CapturedImage(
  path: 'missing.jpg',
  origin: ImageOrigin.camera,
  width: 720,
  height: 1280,
);

Future<void> _show(WidgetTester tester, List<double> scores) {
  return tester.pumpWidget(
    MaterialApp(
      home: ResultPage(
        image: _image,
        result: InferenceResult.fromScores(
          labels: const ['dermatofitosis', 'piel_sana'],
          scores: scores,
          modelVersion: 'test',
          elapsed: Duration.zero,
        ),
      ),
    ),
  );
}

void main() {
  // HU07, scenario 1.
  testWidgets('a finding shows the disease and its confidence', (tester) async {
    await _show(tester, [0.91, 0.09]);

    expect(find.text('Indicios de dermatofitosis'), findsOneWidget);
    expect(find.text('Confianza: 91 %'), findsOneWidget);
    expect(find.text(HealthStatus.lesion.label), findsOneWidget);
    expect(find.text(ResultPage.disclaimerText), findsOneWidget);
  });

  // HU07, scenario 2.
  testWidgets('healthy skin is shown with its confidence', (tester) async {
    await _show(tester, [0.1, 0.9]);

    expect(find.text('Piel sana'), findsWidgets);
    expect(find.text('Confianza: 90 %'), findsOneWidget);
    expect(find.text(HealthStatus.healthy.label), findsOneWidget);
  });

  // HU08: no single class is presented below 60 % confidence.
  testWidgets('low confidence shows an inconclusive result', (tester) async {
    await _show(tester, [0.55, 0.45]);

    expect(find.text(ResultPage.inconclusiveTitle), findsOneWidget);
    expect(find.text(ResultPage.inconclusiveAdvice), findsOneWidget);
    expect(find.text(HealthStatus.review.label), findsOneWidget);
    expect(find.text('Indicios de dermatofitosis'), findsNothing);
    expect(find.text('55 %'), findsOneWidget);
    expect(find.text('45 %'), findsOneWidget);
    expect(find.text(ResultPage.disclaimerText), findsOneWidget);
  });
}
