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
    final analysis = resizeBilinear(rgb, image.width, box, qualityAnalysisSize);
    final quality = assessQuality(
      analysis,
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

  /// Measures sharpness and exposure on a square RGB image of [size] pixels.
  static ImageQualityReport assessQuality(
    Float32List rgb,
    int size, {
    ImageQualityThresholds thresholds = const ImageQualityThresholds(),
  }) {
    final pixels = size * size;
    final gray = Float32List(pixels);
    var brightnessSum = 0.0;
    var darkCount = 0;
    var brightCount = 0;
    for (var i = 0, p = 0; i < pixels; i++, p += 3) {
      final luminance =
          0.299 * rgb[p] + 0.587 * rgb[p + 1] + 0.114 * rgb[p + 2];
      gray[i] = luminance;
      brightnessSum += luminance;
      if (luminance < _darkPixel) darkCount++;
      if (luminance > _brightPixel) brightCount++;
    }

    // Variance of the 4-neighbor Laplacian: low values mean few sharp edges.
    var sum = 0.0;
    var sumOfSquares = 0.0;
    for (var y = 1; y < size - 1; y++) {
      for (var x = 1; x < size - 1; x++) {
        final i = y * size + x;
        final laplacian =
            gray[i - size] +
            gray[i + size] +
            gray[i - 1] +
            gray[i + 1] -
            4 * gray[i];
        sum += laplacian;
        sumOfSquares += laplacian * laplacian;
      }
    }
    final count = (size - 2) * (size - 2);
    final mean = sum / count;
    final sharpness = sumOfSquares / count - mean * mean;

    final meanBrightness = brightnessSum / pixels;
    final darkRatio = darkCount / pixels;
    final brightRatio = brightCount / pixels;

    return ImageQualityReport(
      sharpness: sharpness,
      meanBrightness: meanBrightness,
      darkRatio: darkRatio,
      brightRatio: brightRatio,
      issues: [
        if (meanBrightness < thresholds.minBrightness ||
            darkRatio > thresholds.maxDarkRatio)
          ImageQualityIssue.dark,
        if (meanBrightness > thresholds.maxBrightness ||
            brightRatio > thresholds.maxBrightRatio)
          ImageQualityIssue.overexposed,
        if (sharpness < thresholds.minSharpness) ImageQualityIssue.blurry,
      ],
    );
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
