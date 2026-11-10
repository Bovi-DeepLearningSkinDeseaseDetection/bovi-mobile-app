import 'clinical_code_catalog.dart';

/// Texts shown to the farmer for each class of the model.
///
/// The keys are the class names of `etiquetas.txt`. A class that is not listed
/// here is still shown, using its label as the name.
///
/// The standard codes of each class (HU07) are in [ClinicalCodeCatalog].
/// PENDING: the information sheets of HU09.
class LesionClassCatalog {
  LesionClassCatalog._();

  static const _healthyLabels = {'piel_sana', 'sana'};

  static const _names = {
    'piel_sana': 'Piel sana',
    'sana': 'Piel sana',
    'dermatofitosis': 'Dermatofitosis',
    'papilomatosis': 'Papilomatosis',
    'sarna': 'Sarna',
    'miasis': 'Miasis',
  };

  /// Classes of the model, healthy skin first, for the history filters.
  static const labels = [
    'piel_sana',
    'dermatofitosis',
    'papilomatosis',
    'sarna',
    'miasis',
  ];

  static bool isHealthy(String label) =>
      _healthyLabels.contains(label.toLowerCase());

  /// Name of the class, for example "Dermatofitosis".
  static String displayName(String label) =>
      _names[label.toLowerCase()] ?? _humanize(label);

  /// Headline of the result. The app reports signs, never a diagnosis.
  static String resultTitle(String label) => isHealthy(label)
      ? displayName(label)
      : 'Indicios de ${displayName(label).toLowerCase()}';

  static String _humanize(String label) {
    final text = label.replaceAll('_', ' ').trim();
    if (text.isEmpty) return label;
    return text[0].toUpperCase() + text.substring(1);
  }
}
