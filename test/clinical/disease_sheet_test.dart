import 'dart:convert';
import 'dart:io';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/captured_image.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/origin_image.dart';
import 'package:bov_mobile_app/clinical/infrastructure/catalog/disease_sheet_catalog.dart';
import 'package:bov_mobile_app/clinical/infrastructure/catalog/lesion_class_catalog.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/disease_sheet_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/pages/result_page.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/result/result_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DiseaseSheetCatalog _catalog() => DiseaseSheetCatalog.fromJson(
  jsonDecode(File(DiseaseSheetCatalog.asset).readAsStringSync())
      as Map<String, dynamic>,
);

InferenceResult _result(String top, double confidence) =>
    InferenceResult.fromScores(
      labels: [top, 'piel_sana'],
      scores: [confidence, 1 - confidence],
      modelVersion: 'test',
      elapsed: Duration.zero,
    );

const _image = CapturedImage(
  path: 'missing.jpg',
  origin: ImageOrigin.camera,
  width: 720,
  height: 1280,
);

void main() {
  final catalog = _catalog();

  // HU09, scenario 1: signs, contagion and prevention for the 4 diseases.
  test('each disease of the model has a complete sheet', () {
    final diseases = LesionClassCatalog.labels.where(
      (label) => !LesionClassCatalog.isHealthy(label),
    );
    expect(diseases, hasLength(4));
    for (final label in diseases) {
      final sheet = catalog.sheetOf(label);
      expect(sheet, isNotNull, reason: label);
      expect(sheet!.summary, isNotEmpty);
      expect(sheet.signs, isNotEmpty);
      expect(sheet.contagion, isNotEmpty);
      expect(sheet.peopleNote, isNotEmpty);
      expect(sheet.prevention, isNotEmpty);
      expect(sheet.whenToCallVet, isNotEmpty);
      expect(sheet.sources, isNotEmpty);
      for (final source in sheet.sources) {
        expect(source.url, startsWith('https://'));
      }
    }
  });

  test('healthy skin and inconclusive results have no sheet', () {
    expect(catalog.sheetFor(_result('piel_sana', 0.9)), isNull);
    expect(catalog.sheetFor(_result('sarna', 0.5)), isNull);
    expect(catalog.sheetFor(_result('sarna', 0.9))?.label, 'sarna');
  });

  // HU09, scenarios 1 and 2.
  testWidgets('"Ver más" opens the sheet, which keeps the notice', (
    tester,
  ) async {
    final result = _result('miasis', 0.9);
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(
          image: _image,
          result: result,
          sheet: catalog.sheetFor(result),
        ),
      ),
    );
    await tester.ensureVisible(find.text(ResultTexts.moreLabel));
    await tester.tap(find.text(ResultTexts.moreLabel));
    await tester.pumpAndSettle();

    expect(find.byType(DiseaseSheetPage), findsOneWidget);
    expect(find.text('Miasis'), findsOneWidget);
    expect(find.text(DiseaseSheetPage.signsTitle), findsOneWidget);
    expect(find.text('No se contagia por contacto'), findsOneWidget);
    expect(find.text('Puede afectar a personas'), findsOneWidget);
    // The sheet is a lazy list: scroll to the notice at its end.
    await tester.scrollUntilVisible(
      find.text(ResultTexts.disclaimerText),
      300,
      scrollable: find.descendant(
        of: find.byType(DiseaseSheetPage),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text(ResultTexts.disclaimerText), findsOneWidget);
  });

  testWidgets('a result without a sheet does not offer "Ver más"', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(image: _image, result: _result('piel_sana', 0.9)),
      ),
    );
    expect(find.text(ResultTexts.moreLabel), findsNothing);
  });

  // HU08, scenario 2.
  testWidgets('an inconclusive result offers "Tomar otra foto"', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(image: _image, result: _result('sarna', 0.5)),
      ),
    );
    expect(find.text(ResultTexts.inconclusiveRetakeLabel), findsOneWidget);
    expect(find.text(ResultTexts.retakeLabel), findsNothing);
  });
}
