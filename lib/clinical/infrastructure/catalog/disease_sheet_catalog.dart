import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/model/value_objects/disease_sheet.dart';
import '../../domain/model/value_objects/inference_result.dart';
import 'lesion_class_catalog.dart';

/// Information sheets of the diseases of the model (HU09), read from
/// `assets/catalog/disease_sheets.json` so they work without internet.
class DiseaseSheetCatalog {
  static const asset = 'assets/catalog/disease_sheets.json';

  final String version;
  final Map<String, DiseaseSheet> _sheets;

  DiseaseSheetCatalog(this.version, this._sheets);

  factory DiseaseSheetCatalog.fromJson(Map<String, dynamic> json) {
    final sheets = json['sheets'] as Map<String, dynamic>;
    return DiseaseSheetCatalog(json['catalogVersion'] as String, {
      for (final entry in sheets.entries)
        entry.key.toLowerCase(): DiseaseSheet.fromJson(
          entry.key.toLowerCase(),
          entry.value as Map<String, dynamic>,
        ),
    });
  }

  static Future<DiseaseSheetCatalog> load([AssetBundle? bundle]) async {
    final text = await (bundle ?? rootBundle).loadString(asset);
    return DiseaseSheetCatalog.fromJson(
      jsonDecode(text) as Map<String, dynamic>,
    );
  }

  DiseaseSheet? sheetOf(String label) => _sheets[label.toLowerCase()];

  /// Sheet of the detected disease. Healthy skin and inconclusive results
  /// have none: the sheet is shown only for one of the diseases (HU09).
  DiseaseSheet? sheetFor(InferenceResult result) {
    if (!result.isConclusive) return null;
    final label = result.top.label;
    return LesionClassCatalog.isHealthy(label) ? null : sheetOf(label);
  }
}
