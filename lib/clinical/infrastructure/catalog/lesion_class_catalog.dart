/// Texts shown to the farmer for each class of the model.
///
/// The keys are the class names of `etiquetas.txt`. A class that is not listed
/// here is still shown, using its label as the name.
///
/// PENDING: the VeNom codes and the information sheets (HU07, HU09) are not
/// here yet because they must be validated by a veterinarian first.
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
