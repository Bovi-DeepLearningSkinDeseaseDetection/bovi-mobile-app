import 'dart:math' as math;

import 'origin_image.dart';

/// Image obtained from the camera or the gallery, before it is analyzed.
class CapturedImage {
  /// Shortest side required for a 720p image, in either orientation.
  static const minimumShortSide = 720;

  final String path;
  final ImageOrigin origin;
  final int width;
  final int height;

  const CapturedImage({
    required this.path,
    required this.origin,
    required this.width,
    required this.height,
  });

  bool get meetsMinimumResolution =>
      math.min(width, height) >= minimumShortSide;
}
