import 'dart:typed_data';

/// Tensor ready for the classification model (HU05).
///
/// Shape [1, 224, 224, 3], RGB in row-major order, float32 values in 0-255.
/// The values are not normalized because the model does it internally.
class ModelInput {
  static const size = 224;
  static const channels = 3;
  static const shape = [1, size, size, channels];

  final Float32List data;

  ModelInput(this.data) {
    if (data.length != size * size * channels) {
      throw ArgumentError.value(
        data.length,
        'data',
        'Expected ${size * size * channels} values',
      );
    }
  }
}
