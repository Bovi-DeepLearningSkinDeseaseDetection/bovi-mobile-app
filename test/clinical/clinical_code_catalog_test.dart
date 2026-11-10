import 'dart:convert';
import 'dart:io';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/clinical_code.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/inference_result.dart';
import 'package:bov_mobile_app/clinical/infrastructure/catalog/clinical_code_catalog.dart';
import 'package:bov_mobile_app/clinical/infrastructure/catalog/lesion_class_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

ClinicalCodeCatalog _catalog() => ClinicalCodeCatalog.fromJson(
  jsonDecode(File(ClinicalCodeCatalog.asset).readAsStringSync())
      as Map<String, dynamic>,
);

List<String> _modelLabels() => File('tensor-flow-package/etiquetas.txt')
    .readAsLinesSync()
    .map((line) => line.trim())
    .where((line) => line.isNotEmpty)
    .toList();

InferenceResult _result(String top, double confidence) =>
    InferenceResult.fromScores(
      labels: [top, 'otra'],
      scores: [confidence, 1 - confidence],
      modelVersion: 'test',
      elapsed: Duration.zero,
    );

void main() {
  final catalog = _catalog();

  // HU07, scenario 1: every disease of the model has its standard codes.
  test('each disease has a MeSH disease, cattle and NCBI agent code', () {
    final diseases = _modelLabels().where(
      (label) => !LesionClassCatalog.isHealthy(label),
    );
    expect(diseases, hasLength(4));
    for (final label in diseases) {
      final codes = catalog.codesOf(label);
      final mesh = codes.where((c) => c.system == ClinicalCode.meshSystem);
      final agents = codes.where((c) => c.isOrganism);
      expect(mesh.length, 2, reason: label);
      expect(
        mesh.map((c) => c.code),
        contains('D002418'),
        reason: '$label is a cattle disease',
      );
      expect(agents, hasLength(1), reason: label);
      for (final code in codes) {
        expect(code.code, isNotEmpty);
        expect(code.display, isNotEmpty);
      }
    }
  });

  test('the codes match the verified identifiers', () {
    String codes(String label) =>
        catalog.codesOf(label).map((c) => c.toString()).join(', ');
    expect(
      codes('dermatofitosis'),
      'MeSH D014005, MeSH D002418, NCBI Taxon 63417',
    );
    expect(
      codes('papilomatosis'),
      'MeSH D030361, MeSH D002418, NCBI Taxon 10571',
    );
    expect(codes('sarna'), 'MeSH D008924, MeSH D002418, NCBI Taxon 420257');
    expect(codes('miasis'), 'MeSH D009198, MeSH D002418, NCBI Taxon 115425');
  });

  // HU07, scenario 2, and HU08: no disease code for healthy or unsure.
  test('healthy skin and inconclusive results have no code', () {
    expect(catalog.codesFor(_result('piel_sana', 0.9)), isEmpty);
    expect(catalog.codesFor(_result('dermatofitosis', 0.5)), isEmpty);
    expect(catalog.codesFor(_result('dermatofitosis', 0.9)), hasLength(3));
  });

  test('the codes can be looked up in their public registry', () {
    final codes = catalog.codesOf('miasis');
    expect(codes.first.url, 'https://id.nlm.nih.gov/mesh/D009198');
    expect(codes.last.url, 'http://purl.obolibrary.org/obo/NCBITaxon_115425');
  });
}
