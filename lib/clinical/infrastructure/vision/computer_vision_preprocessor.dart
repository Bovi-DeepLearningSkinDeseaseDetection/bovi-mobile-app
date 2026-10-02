import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/model/value_objects/image_quality.dart';
import '../../domain/model/value_objects/model_input.dart';

/// Square region of the source image, in pixels.
typedef CropBox = ({int left, int top, int side});

/// Output of the preprocessing step.
class PreprocessingResult {
  final ImageQualityReport quality;
  final ModelInput input;
  final Duration elapsed;

  const PreprocessingResult({
    required this.quality,
    required this.input,
    required this.elapsed,
  });
}

/// Validates the photo quality (HU04) and turns it into the model input (HU05).
///
/// It must reproduce the training loader exactly, otherwise the model sees
/// different pixels than the ones it learned from:
/// `image_dataset_from_directory(image_size=(224, 224),
/// crop_to_aspect_ratio=True)`, that is, a centered square crop followed by
/// `tf.image.resize` (bilinear, half-pixel centers, no antialiasing).
class ComputerVisionPreprocessor {
  /// Fixed size where quality is measured, so the sharpness thresholds work
  /// the same for dataset photos and phone photos of any resolution.
  static const qualityAnalysisSize = 448;

  // Sharpness is measured per tile on an 8×8 grid and the 90th percentile is
  // kept, so a sharp photo of smooth skin is judged by its textured parts
  // (hair, lesion borders) instead of being averaged with the flat areas.
  static const _sharpnessGrid = 8;
  static const _sharpnessPercentile = 0.9;

  // Luminance limits for a pixel to count as almost black or almost white.
  static const _darkPixel = 30;
  static const _brightPixel = 245;

  final ImageQualityThresholds thresholds;

  const ComputerVisionPreprocessor({
    this.thresholds = const ImageQualityThresholds(),
  });

  /// Processes the image file in a background isolate.
  Future<PreprocessingResult> process(String path) {
    final thresholds = this.thresholds;
    return Isolate.run(
      () => processBytes(File(path).readAsBytesSync(), thresholds: thresholds),
    );
  }

  static PreprocessingResult processBytes(
    Uint8List bytes, {
    ImageQualityThresholds thresholds = const ImageQualityThresholds(),
  }) {
    final stopwatch = Stopwatch()..start();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The image format is not supported.');
    }
    // Camera photos are often stored rotated with an EXIF orientation tag.
    final image = _toRgb8(img.bakeOrientation(decoded));
    final rgb = image.getBytes(order: img.ChannelOrder.rgb);
    final box = centerSquare(image.width, image.height);

    final input = resizeBilinear(rgb, image.width, box, ModelInput.size);
    final gray = areaGray(rgb, image.width, box, qualityAnalysisSize);
    final quality = assessQuality(
      gray,
      qualityAnalysisSize,
      thresholds: thresholds,
    );

    return PreprocessingResult(
      quality: quality,
      input: ModelInput(input),
      elapsed: stopwatch.elapsed,
    );
  }

  /// Largest centered square, as Keras `smart_resize` computes it.
  static CropBox centerSquare(int width, int height) {
    final side = math.min(width, height);
    return (left: (width - side) ~/ 2, top: (height - side) ~/ 2, side: side);
  }

  /// Crops [box] from an RGB buffer and resizes it to [size]×[size] with the
  /// same sampling as `tf.image.resize(method='bilinear', antialias=False)`.
  static Float32List resizeBilinear(
    Uint8List rgb,
    int sourceWidth,
    CropBox box,
    int size,
  ) {
    const channels = 3;
    final scale = box.side / size;
    final lower = Int32List(size);
    final upper = Int32List(size);
    final lerp = Float64List(size);
    for (var i = 0; i < size; i++) {
      // Half-pixel centers: the output pixel center maps back to the source.
      final position = (i + 0.5) * scale - 0.5;
      final floor = position.floorToDouble();
      lower[i] = math.max(floor.toInt(), 0);
      upper[i] = math.min(position.ceil(), box.side - 1);
      lerp[i] = position - floor;
    }

    final output = Float32List(size * size * channels);
    var o = 0;
    for (var y = 0; y < size; y++) {
      final topRow = (box.top + lower[y]) * sourceWidth;
      final bottomRow = (box.top + upper[y]) * sourceWidth;
      final yLerp = lerp[y];
      for (var x = 0; x < size; x++) {
        final left = box.left + lower[x];
        final right = box.left + upper[x];
        final xLerp = lerp[x];
        final topLeft = (topRow + left) * channels;
        final topRight = (topRow + right) * channels;
        final bottomLeft = (bottomRow + left) * channels;
        final bottomRight = (bottomRow + right) * channels;
        for (var c = 0; c < channels; c++) {
          final top =
              rgb[topLeft + c] + (rgb[topRight + c] - rgb[topLeft + c]) * xLerp;
          final bottom =
              rgb[bottomLeft + c] +
              (rgb[bottomRight + c] - rgb[bottomLeft + c]) * xLerp;
          output[o++] = top + (bottom - top) * yLerp;
        }
      }
    }
    return output;
  }

  /// Crops [box] from an RGB buffer and reduces it to a [size]×[size]
  /// grayscale image by averaging each area of source pixels. Averaging
  /// smooths out sensor noise, which would otherwise look like sharp detail.
  static Float32List areaGray(
    Uint8List rgb,
    int sourceWidth,
    CropBox box,
    int size,
  ) {
    final scale = box.side / size;
    final start = Int32List(size + 1);
    for (var i = 0; i <= size; i++) {
      start[i] = math.min((i * scale).floor(), box.side);
    }
    final output = Float32List(size * size);
    for (var y = 0; y < size; y++) {
      final y0 = start[y];
      final y1 = math.max(start[y + 1], y0 + 1);
      for (var x = 0; x < size; x++) {
        final x0 = start[x];
        final x1 = math.max(start[x + 1], x0 + 1);
        var sum = 0.0;
        for (var sy = y0; sy < y1; sy++) {
          var p = ((box.top + sy) * sourceWidth + box.left + x0) * 3;
          for (var sx = x0; sx < x1; sx++, p += 3) {
            sum += 0.299 * rgb[p] + 0.587 * rgb[p + 1] + 0.114 * rgb[p + 2];
          }
        }
        output[y * size + x] = sum / ((y1 - y0) * (x1 - x0));
      }
    }
    return output;
  }

  /// Measures sharpness and exposure on a square grayscale image.
  static ImageQualityReport assessQuality(
    Float32List gray,
    int size, {
    ImageQualityThresholds thresholds = const ImageQualityThresholds(),
  }) {
    final pixels = size * size;
    var brightnessSum = 0.0;
    var darkCount = 0;
    var brightCount = 0;
    for (final luminance in gray) {
      brightnessSum += luminance;
      if (luminance < _darkPixel) darkCount++;
      if (luminance > _brightPixel) brightCount++;
    }
    final meanBrightness = brightnessSum / pixels;
    final darkRatio = darkCount / pixels;
    final brightRatio = brightCount / pixels;
    final sharpness = tileSharpness(gray, size);

    final t = thresholds;
    final issues = <ImageQualityIssue>[];
    final warnings = <ImageQualityIssue>[];
    void classify(ImageQualityIssue issue, bool reject, bool warn) {
      if (reject) {
        issues.add(issue);
      } else if (warn) {
        warnings.add(issue);
      }
    }

    classify(
      ImageQualityIssue.dark,
      meanBrightness < t.rejectMinBrightness ||
          darkRatio > t.rejectMaxDarkRatio,
      meanBrightness < t.warnMinBrightness || darkRatio > t.warnMaxDarkRatio,
    );
    classify(
      ImageQualityIssue.overexposed,
      meanBrightness > t.rejectMaxBrightness ||
          brightRatio > t.rejectMaxBrightRatio,
      meanBrightness > t.warnMaxBrightness ||
          brightRatio > t.warnMaxBrightRatio,
    );
    classify(
      ImageQualityIssue.blurry,
      sharpness < t.rejectSharpness,
      sharpness < t.warnSharpness,
    );

    return ImageQualityReport(
      sharpness: sharpness,
      meanBrightness: meanBrightness,
      darkRatio: darkRatio,
      brightRatio: brightRatio,
      issues: issues,
      warnings: warnings,
    );
  }

  /// Variance of the 4-neighbor Laplacian in each tile of the grid, keeping
  /// the 90th percentile. Low values mean the photo has few sharp edges.
  static double tileSharpness(Float32List gray, int size) {
    final tile = size ~/ _sharpnessGrid;
    final variances = <double>[];
    for (var ty = 0; ty < _sharpnessGrid; ty++) {
      for (var tx = 0; tx < _sharpnessGrid; tx++) {
        var sum = 0.0;
        var sumOfSquares = 0.0;
        var count = 0;
        final yEnd = math.min(size - 1, (ty + 1) * tile);
        final xEnd = math.min(size - 1, (tx + 1) * tile);
        for (var y = math.max(1, ty * tile); y < yEnd; y++) {
          for (var x = math.max(1, tx * tile); x < xEnd; x++) {
            final i = y * size + x;
            final laplacian =
                gray[i - size] +
                gray[i + size] +
                gray[i - 1] +
                gray[i + 1] -
                4 * gray[i];
            sum += laplacian;
            sumOfSquares += laplacian * laplacian;
            count++;
          }
        }
        final mean = sum / count;
        variances.add(sumOfSquares / count - mean * mean);
      }
    }
    variances.sort();
    return variances[((variances.length - 1) * _sharpnessPercentile).round()];
  }

  // Grayscale, palette and alpha images become plain 8-bit RGB, like
  // `decode_image(channels=3)` does in the training loader.
  static img.Image _toRgb8(img.Image image) {
    if (image.format == img.Format.uint8 &&
        image.numChannels == 3 &&
        !image.hasPalette) {
      return image;
    }
    return image.convert(format: img.Format.uint8, numChannels: 3);
  }
}
