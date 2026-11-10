import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/model/value_objects/clinical_code.dart';
import '../../domain/model/value_objects/inference_result.dart';

/// Standard codes of each class of the model (HU07), read from
/// `assets/catalog/clinical_codes.json`.
class ClinicalCodeCatalog {
  static const asset = 'assets/catalog/clinical_codes.json';

  /// Edition of the catalog; it is saved with each evaluation (HU10).
  final String version;
  final Map<String, List<ClinicalCode>> _codes;

  /// [version] and the codes of each class, keyed by the model label.
  ClinicalCodeCatalog(this.version, this._codes);

  factory ClinicalCodeCatalog.fromJson(Map<String, dynamic> json) {
    final classes = json['classes'] as Map<String, dynamic>;
    return ClinicalCodeCatalog(json['catalogVersion'] as String, {
      for (final entry in classes.entries)
        entry.key.toLowerCase(): [
          for (final code in entry.value as List)
            ClinicalCode.fromJson(code as Map<String, dynamic>),
        ],
    });
  }

  static Future<ClinicalCodeCatalog> load([AssetBundle? bundle]) async {
    final text = await (bundle ?? rootBundle).loadString(asset);
    return ClinicalCodeCatalog.fromJson(
      jsonDecode(text) as Map<String, dynamic>,
    );
  }

  /// Codes of a class; empty for healthy skin and unknown classes.
  List<ClinicalCode> codesOf(String label) =>
      _codes[label.toLowerCase()] ?? const [];

  /// Codes of the result. An inconclusive result shows no single class
  /// (HU08), so it has no code either.
  List<ClinicalCode> codesFor(InferenceResult result) =>
      result.isConclusive ? codesOf(result.top.label) : const [];
}
