import 'dart:typed_data';

/// Where the photos of the evaluations live on the phone.
abstract class EvaluationPhotoStore {
  /// Absolute path of a stored file.
  Future<String> pathOf(String fileName);

  /// Keeps a photo downloaded from the cloud (HU13) as `<id>.jpg` and
  /// makes its thumbnail. Returns both file names.
  Future<({String image, String thumbnail})> saveDownloaded(
    Uint8List bytes,
    String id,
  );
}
