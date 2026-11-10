/// Code of a public, universal terminology, as a FHIR `Coding`: the
/// [system] URI plus the [code] identify the concept anywhere (HU07).
///
/// VeNom has no codes for cattle, so the app uses MeSH for the disease and
/// NCBI Taxonomy for its causal agent.
class ClinicalCode {
  static const meshSystem = 'http://id.nlm.nih.gov/mesh';
  static const ncbiTaxonSystem = 'http://purl.obolibrary.org/obo/NCBITaxon';

  final String system;
  final String code;

  /// Official term of the terminology, for example "Tinea".
  final String display;

  const ClinicalCode({
    required this.system,
    required this.code,
    required this.display,
  });

  factory ClinicalCode.fromJson(Map<String, dynamic> json) => ClinicalCode(
    system: json['system'] as String,
    code: json['code'] as String,
    display: json['display'] as String,
  );

  /// Short name of the terminology, for example "MeSH".
  String get systemName => switch (system) {
    meshSystem => 'MeSH',
    ncbiTaxonSystem => 'NCBI Taxon',
    _ => system,
  };

  /// Whether the code names the causal organism instead of the disease.
  bool get isOrganism => system == ncbiTaxonSystem;

  /// Address where anyone can look the code up.
  String get url => switch (system) {
    meshSystem => 'https://id.nlm.nih.gov/mesh/$code',
    ncbiTaxonSystem => 'http://purl.obolibrary.org/obo/NCBITaxon_$code',
    _ => '$system/$code',
  };

  @override
  bool operator ==(Object other) =>
      other is ClinicalCode && other.system == system && other.code == code;

  @override
  int get hashCode => Object.hash(system, code);

  @override
  String toString() => '$systemName $code';
}
