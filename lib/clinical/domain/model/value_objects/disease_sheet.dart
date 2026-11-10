/// Public reference that supports the content of a [DiseaseSheet].
class SheetSource {
  final String title;
  final String url;

  const SheetSource({required this.title, required this.url});

  factory SheetSource.fromJson(Map<String, dynamic> json) =>
      SheetSource(title: json['title'] as String, url: json['url'] as String);
}

/// Plain-language information about a detected disease (HU09): visible
/// signs, whether it spreads and non-clinical preventive measures. It never
/// replaces a veterinary diagnosis or prescribes a treatment.
class DiseaseSheet {
  /// Class of the model, for example "dermatofitosis".
  final String label;
  final String summary;
  final List<String> signs;
  final bool contagious;
  final String contagion;
  final bool affectsPeople;
  final String peopleNote;
  final List<String> prevention;
  final String whenToCallVet;
  final List<SheetSource> sources;

  const DiseaseSheet({
    required this.label,
    required this.summary,
    required this.signs,
    required this.contagious,
    required this.contagion,
    required this.affectsPeople,
    required this.peopleNote,
    required this.prevention,
    required this.whenToCallVet,
    required this.sources,
  });

  factory DiseaseSheet.fromJson(String label, Map<String, dynamic> json) {
    List<String> texts(String key) =>
        (json[key] as List).cast<String>().toList(growable: false);
    return DiseaseSheet(
      label: label,
      summary: json['summary'] as String,
      signs: texts('signs'),
      contagious: json['contagious'] as bool,
      contagion: json['contagion'] as String,
      affectsPeople: json['affectsPeople'] as bool,
      peopleNote: json['peopleNote'] as String,
      prevention: texts('prevention'),
      whenToCallVet: json['whenToCallVet'] as String,
      sources: [
        for (final source in json['sources'] as List)
          SheetSource.fromJson(source as Map<String, dynamic>),
      ],
    );
  }
}
