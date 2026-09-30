/// Problem that makes a photo unsuitable for analysis (HU04).
///
/// Declared in the order the messages are shown: exposure first, because
/// the sharpness measurement is unreliable on a dark or burned-out image.
enum ImageQualityIssue {
  dark(
    'La imagen está muy oscura. Tome la foto con luz natural, '
    'sin sol directo sobre la lesión.',
  ),
  overexposed(
    'La imagen tiene demasiada luz. Tome la foto con luz natural, '
    'sin sol directo sobre la lesión.',
  ),
  blurry(
    'La imagen está borrosa. Mantenga el celular quieto '
    'y vuelva a tomar la foto.',
  );

  const ImageQualityIssue(this.message);

  final String message;
}

/// Limits used to accept or reject a photo.
///
/// Calibrated with 49 valid and 50 defective 640×640 dataset photos
/// (assets/images/correct and incorrect), placing each limit between the
/// worst valid photo and the closest defective one. They must be checked
/// again with real photos taken at the farm (HU04, scenario 4).
class ImageQualityThresholds {
  /// Minimum variance of the Laplacian on the grayscale analysis image.
  final double minSharpness;

  /// Mean luminance (0-255) below which the photo is too dark.
  final double minBrightness;

  /// Mean luminance (0-255) above which the photo is overexposed.
  final double maxBrightness;

  /// Maximum share of pixels that are almost black.
  final double maxDarkRatio;

  /// Maximum share of pixels that are almost white.
  final double maxBrightRatio;

  const ImageQualityThresholds({
    this.minSharpness = 200,
    this.minBrightness = 55,
    this.maxBrightness = 170,
    this.maxDarkRatio = 0.45,
    this.maxBrightRatio = 0.25,
  });
}

/// Quality measurements of a photo and the problems found.
class ImageQualityReport {
  final double sharpness;
  final double meanBrightness;
  final double darkRatio;
  final double brightRatio;
  final List<ImageQualityIssue> issues;

  const ImageQualityReport({
    required this.sharpness,
    required this.meanBrightness,
    required this.darkRatio,
    required this.brightRatio,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;

  /// Message for the most relevant problem, or null if the photo is valid.
  String? get message => isValid ? null : issues.first.message;

  @override
  String toString() =>
      'ImageQualityReport(sharpness: ${sharpness.toStringAsFixed(1)}, '
      'brightness: ${meanBrightness.toStringAsFixed(1)}, '
      'dark: ${darkRatio.toStringAsFixed(2)}, '
      'bright: ${brightRatio.toStringAsFixed(2)}, issues: $issues)';
}
