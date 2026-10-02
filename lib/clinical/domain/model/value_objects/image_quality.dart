/// Problem that can make a photo unsuitable for analysis (HU04).
///
/// Declared in the order the messages are shown: exposure first, because
/// the sharpness measurement is unreliable on a dark or burned-out image.
enum ImageQualityIssue {
  dark(
    message:
        'La imagen está muy oscura. Tome la foto con luz natural, '
        'sin sol directo sobre la lesión.',
    warningMessage:
        'La foto está algo oscura. Si puede, tómela con más luz natural.',
  ),
  overexposed(
    message:
        'La imagen tiene demasiada luz. Tome la foto con luz natural, '
        'sin sol directo sobre la lesión.',
    warningMessage:
        'La foto tiene bastante luz. Si puede, evite el sol directo '
        'sobre la lesión.',
  ),
  blurry(
    message:
        'La imagen está borrosa. Mantenga el celular quieto '
        'y vuelva a tomar la foto.',
    warningMessage:
        'La foto podría estar un poco borrosa. Para un resultado más '
        'confiable, mantenga el celular quieto y vuelva a tomarla.',
  );

  const ImageQualityIssue({
    required this.message,
    required this.warningMessage,
  });

  /// Shown when the photo is rejected.
  final String message;

  /// Shown when the photo is doubtful but can still be analyzed.
  final String warningMessage;
}

/// Limits used to accept, warn about or reject a photo.
///
/// Each criterion has two levels. Past the reject level the photo is not
/// analyzed. Between both levels the user is warned and may analyze it
/// anyway, so phones with weaker cameras are guided instead of blocked.
///
/// Calibrated with 49 valid and 50 defective 640×640 dataset photos
/// (assets/images/correct and incorrect) and with photos taken with a phone.
/// They must be checked again with real photos taken at the farm
/// (HU04, scenario 4).
class ImageQualityThresholds {
  /// Sharpness (90th percentile of the tile Laplacian variance) below which
  /// the photo is rejected and below which it is doubtful.
  final double rejectSharpness;
  final double warnSharpness;

  /// Mean luminance (0-255) below which the photo is too dark.
  final double rejectMinBrightness;
  final double warnMinBrightness;

  /// Share of almost black pixels above which the photo is too dark.
  final double rejectMaxDarkRatio;
  final double warnMaxDarkRatio;

  /// Mean luminance (0-255) above which the photo is overexposed.
  final double rejectMaxBrightness;
  final double warnMaxBrightness;

  /// Share of almost white pixels above which the photo is overexposed.
  final double rejectMaxBrightRatio;
  final double warnMaxBrightRatio;

  const ImageQualityThresholds({
    this.rejectSharpness = 150,
    this.warnSharpness = 600,
    this.rejectMinBrightness = 40,
    this.warnMinBrightness = 60,
    this.rejectMaxDarkRatio = 0.6,
    this.warnMaxDarkRatio = 0.45,
    this.rejectMaxBrightness = 190,
    this.warnMaxBrightness = 170,
    this.rejectMaxBrightRatio = 0.4,
    this.warnMaxBrightRatio = 0.25,
  });
}

/// Quality measurements of a photo and the problems found.
class ImageQualityReport {
  final double sharpness;
  final double meanBrightness;
  final double darkRatio;
  final double brightRatio;

  /// Problems that prevent the analysis.
  final List<ImageQualityIssue> issues;

  /// Doubtful aspects; the user may still analyze the photo.
  final List<ImageQualityIssue> warnings;

  const ImageQualityReport({
    required this.sharpness,
    required this.meanBrightness,
    required this.darkRatio,
    required this.brightRatio,
    required this.issues,
    this.warnings = const [],
  });

  /// True when nothing prevents the analysis, even if there are warnings.
  bool get isValid => issues.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  /// Message for the most relevant problem, or null if the photo is fine.
  String? get message {
    if (issues.isNotEmpty) return issues.first.message;
    if (warnings.isNotEmpty) return warnings.first.warningMessage;
    return null;
  }

  @override
  String toString() =>
      'ImageQualityReport(sharpness: ${sharpness.toStringAsFixed(1)}, '
      'brightness: ${meanBrightness.toStringAsFixed(1)}, '
      'dark: ${darkRatio.toStringAsFixed(2)}, '
      'bright: ${brightRatio.toStringAsFixed(2)}, '
      'issues: $issues, warnings: $warnings)';
}
