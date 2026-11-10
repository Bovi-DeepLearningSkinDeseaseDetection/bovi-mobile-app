/// Texts of the result screen (HU07, HU08, HU09, HU10).
class ResultTexts {
  ResultTexts._();

  static const pageTitle = 'Diagnóstico';
  static const historyTitle = 'Evaluación';
  static const sectionTitle = 'Resultado preliminar';
  static const inconclusiveTitle = 'Resultado no concluyente';
  static const inconclusiveAdvice =
      'Repita la foto siguiendo la guía de encuadre o consulte a un médico '
      'veterinario.';
  static const lesionAdvice =
      'Se observan signos compatibles con una posible lesión en la piel. '
      'Te recomendamos consultar con un profesional veterinario.';
  static const healthyAdvice = 'No se observan signos de lesión en la piel.';
  static const disclaimerText =
      'Este resultado es preliminar y no reemplaza el diagnóstico de un '
      'médico veterinario.';
  static const retakeLabel = 'Nuevo escaneo';

  /// HU08, scenario 2: the action an inconclusive result recommends.
  static const inconclusiveRetakeLabel = 'Tomar otra foto';
  static const moreLabel = 'Ver más';
  static const savingText = 'Guardando en el historial…';
  static const savedText = 'Guardado en el historial';
  static const notSavedText = 'No se pudo guardar en el historial';
  static const codesTitle = 'Codificación clínica';
  static const probabilitiesTitle = 'Probabilidad por clase';
}
