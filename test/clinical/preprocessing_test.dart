import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/image_quality.dart';
import 'package:bov_mobile_app/clinical/domain/model/value_objects/model_input.dart';
import 'package:bov_mobile_app/clinical/infrastructure/vision/computer_vision_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Mid-gray image with random texture, like a sharp and well-lit photo.
img.Image texturedImage(int width, int height, {int seed = 1}) {
  final random = math.Random(seed);
  final image = img.Image(width: width, height: height);
  for (final pixel in image) {
    final value = 70 + random.nextInt(120);
    pixel
      ..r = value
      ..g = (value * 0.9).round()
      ..b = (value * 0.8).round();
  }
  return image;
}

Uint8List jpg(img.Image image) => img.encodeJpg(image, quality: 95);

List<double> pixelAt(Float32List rgb, int size, int x, int y) {
  final i = (y * size + x) * 3;
  return [rgb[i], rgb[i + 1], rgb[i + 2]];
}

void main() {
  group('HU05: prepare the image for the model', () {
    test('the crop is the largest centered square', () {
      expect(ComputerVisionPreprocessor.centerSquare(720, 1280), (
        left: 0,
        top: 280,
        side: 720,
      ));
      expect(ComputerVisionPreprocessor.centerSquare(1281, 720), (
        left: 280,
        top: 0,
        side: 720,
      ));
    });

    // Scenario 2: any resolution and orientation gives a 224x224x3 tensor.
    for (final (width, height) in [
      (720, 1280),
      (1280, 720),
      (1080, 1920),
      (3000, 4000),
    ]) {
      test('a ${width}x$height photo becomes a 224x224x3 tensor', () {
        final result = ComputerVisionPreprocessor.processBytes(
          jpg(texturedImage(width, height)),
        );
        expect(result.input.data.length, 224 * 224 * 3);
        expect(ModelInput.shape, [1, 224, 224, 3]);
      });
    }

    test('values stay in 0-255 because the model normalizes internally', () {
      final result = ComputerVisionPreprocessor.processBytes(
        jpg(texturedImage(1280, 720)),
      );
      final values = result.input.data;
      expect(values.reduce(math.max), greaterThan(1));
      expect(values.reduce(math.max), lessThanOrEqualTo(255));
      expect(values.reduce(math.min), greaterThanOrEqualTo(0));
    });

    test('resizing uses half-pixel centers like tf.image.resize', () {
      // Halving a 4x4 image must average each 2x2 block.
      final rgb = Uint8List(4 * 4 * 3);
      for (var i = 0; i < 16; i++) {
        rgb.fillRange(i * 3, i * 3 + 3, i * 10);
      }
      final output = ComputerVisionPreprocessor.resizeBilinear(rgb, 4, (
        left: 0,
        top: 0,
        side: 4,
      ), 2);
      // Top-left block holds 0, 10, 40 and 50.
      expect(pixelAt(output, 2, 0, 0), [25, 25, 25]);
      // Bottom-right block holds 100, 110, 140 and 150.
      expect(pixelAt(output, 2, 1, 1), [125, 125, 125]);
    });

    test('resizing to the same size keeps the pixels unchanged', () {
      final rgb = Uint8List.fromList(List.generate(3 * 3 * 3, (i) => i * 9));
      final output = ComputerVisionPreprocessor.resizeBilinear(rgb, 3, (
        left: 0,
        top: 0,
        side: 3,
      ), 3);
      expect(output, rgb.map((v) => v.toDouble()).toList());
    });

    test('the EXIF orientation is applied before cropping', () {
      // Landscape: left half red, right half blue, tagged "rotate 90° CW".
      final image = img.Image(width: 400, height: 200);
      for (final pixel in image) {
        pixel
          ..r = pixel.x < 200 ? 255 : 0
          ..g = 0
          ..b = pixel.x < 200 ? 0 : 255;
      }
      image.exif.imageIfd.orientation = 6;

      final result = ComputerVisionPreprocessor.processBytes(jpg(image));
      final top = pixelAt(result.input.data, 224, 112, 10);
      final bottom = pixelAt(result.input.data, 224, 112, 213);
      // Once rotated, red is on top and blue at the bottom.
      expect(top[0], greaterThan(200));
      expect(top[2], lessThan(60));
      expect(bottom[0], lessThan(60));
      expect(bottom[2], greaterThan(200));
    });

    // Scenario 3: the step takes less than 500 ms.
    test('a 720p camera photo is processed in less than 500 ms', () {
      final bytes = jpg(texturedImage(1280, 720));
      ComputerVisionPreprocessor.processBytes(bytes); // Warm up the JIT.
      final result = ComputerVisionPreprocessor.processBytes(bytes);
      expect(result.elapsed, lessThan(const Duration(milliseconds: 500)));
    });
  });

  group('HU04: validate the image quality', () {
    ImageQualityReport assess(img.Image image) =>
        ComputerVisionPreprocessor.processBytes(jpg(image)).quality;

    img.Image mapValues(img.Image image, num Function(num) transform) {
      final copy = image.clone();
      for (final pixel in copy) {
        pixel
          ..r = transform(pixel.r).clamp(0, 255)
          ..g = transform(pixel.g).clamp(0, 255)
          ..b = transform(pixel.b).clamp(0, 255);
      }
      return copy;
    }

    final sharp = texturedImage(1280, 720);

    // Scenario 1.
    test('a sharp and well-lit photo passes without messages', () {
      final report = assess(sharp);
      expect(report.isValid, isTrue, reason: '$report');
      expect(report.message, isNull);
    });

    // Scenario 2.
    test('a blurry photo is rejected with the blur message', () {
      final report = assess(img.gaussianBlur(sharp.clone(), radius: 12));
      expect(report.issues, contains(ImageQualityIssue.blurry));
      expect(report.message, startsWith('La imagen está borrosa.'));
    });

    // Scenario 3.
    test('a dark photo is rejected and suggests natural light', () {
      final report = assess(mapValues(sharp, (v) => v * 0.15));
      expect(report.issues.first, ImageQualityIssue.dark);
      expect(report.message, contains('luz natural'));
    });

    test('an overexposed photo is rejected and suggests natural light', () {
      final report = assess(mapValues(sharp, (v) => 255 - (255 - v) * 0.1));
      expect(report.issues.first, ImageQualityIssue.overexposed);
      expect(report.message, contains('sin sol directo'));
    });
  });
}
