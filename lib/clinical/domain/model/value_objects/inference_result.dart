/// Probability that the model assigned to one class.
class ClassProbability {
  /// Class name exactly as written in `etiquetas.txt`.
  final String label;

  /// Value between 0 and 1.
  final double probability;

  const ClassProbability(this.label, this.probability);

  /// Probability as a whole percentage, for example "91 %".
  String get percentText => '${(probability * 100).round()} %';
}

/// Output of the classification model for one photo (HU06).
class InferenceResult {
  /// Below this confidence the result is shown as inconclusive (RF11, HU08).
  static const inconclusiveThreshold = 0.60;

  /// One entry per class, in the same order as `etiquetas.txt`.
  final List<ClassProbability> probabilities;

  /// Version of the model that produced the result (RNF17).
  final String modelVersion;

  /// Time the model took to run.
  final Duration elapsed;

  InferenceResult({
    required List<ClassProbability> probabilities,
    required this.modelVersion,
    required this.elapsed,
  }) : probabilities = List.unmodifiable(probabilities) {
    if (probabilities.isEmpty) {
      throw ArgumentError.value(probabilities, 'probabilities', 'Empty');
    }
  }

  /// Pairs each score with its label. The number of classes is not fixed:
  /// it is whatever the labels file contains.
  factory InferenceResult.fromScores({
    required List<String> labels,
    required List<double> scores,
    required String modelVersion,
    required Duration elapsed,
  }) {
    if (labels.length != scores.length) {
      throw ArgumentError(
        'The model returned ${scores.length} scores '
            'but there are ${labels.length} labels.',
      );
    }
    return InferenceResult(
      probabilities: [
        for (var i = 0; i < labels.length; i++)
          ClassProbability(labels[i], scores[i]),
      ],
      modelVersion: modelVersion,
      elapsed: elapsed,
    );
  }

  /// Classes from the most to the least probable.
  List<ClassProbability> get ranked =>
      [...probabilities]..sort((a, b) => b.probability.compareTo(a.probability));

  /// Most probable class.
  ClassProbability get top => ranked.first;

  /// Whether the model is confident enough to show a single class.
  bool get isConclusive => top.probability >= inconclusiveThreshold;
}
