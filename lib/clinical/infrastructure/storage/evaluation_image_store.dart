import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/services/evaluation_photo_store.dart';

/// Keeps a compressed copy of each analyzed photo and its thumbnail in the
/// app documents, so the history does not depend on the original file.
class EvaluationImageStore implements EvaluationPhotoStore {
  static const _folder = 'evaluations';

  // Longest side of the stored photo and of the thumbnail. A 1280 px JPEG at
  // this quality stays well below 500 KB (RNF11).
  static const _photoSide = 1280;
  static const _photoQuality = 80;
  static const _thumbnailSide = 256;
  static const _thumbnailQuality = 75;

  Directory? _directory;

  Future<Directory> directory() async {
    if (_directory != null) return _directory!;
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, _folder));
    await directory.create(recursive: true);
    return _directory = directory;
  }

  /// Absolute path of a stored file.
  @override
  Future<String> pathOf(String fileName) async =>
      p.join((await directory()).path, fileName);

  /// Stores the photo at [sourcePath] as `<id>.jpg` and `<id>_thumb.jpg`
  /// and returns both file names.
  Future<({String image, String thumbnail})> store(
    String sourcePath,
    String id,
  ) async {
    final folder = (await directory()).path;
    final image = '$id.jpg';
    final thumbnail = '${id}_thumb.jpg';
    await Isolate.run(() {
      final decoded = img.decodeImage(File(sourcePath).readAsBytesSync());
      if (decoded == null) {
        throw const FormatException('The image format is not supported.');
      }
      final upright = img.bakeOrientation(decoded);
      File(p.join(folder, image)).writeAsBytesSync(
        img.encodeJpg(_fit(upright, _photoSide), quality: _photoQuality),
      );
      File(p.join(folder, thumbnail)).writeAsBytesSync(
        img.encodeJpg(
          _fit(upright, _thumbnailSide),
          quality: _thumbnailQuality,
        ),
      );
    });
    return (image: image, thumbnail: thumbnail);
  }

  /// The photo came from the cloud already compressed: it is kept as it is
  /// and only the thumbnail is made.
  @override
  Future<({String image, String thumbnail})> saveDownloaded(
    Uint8List bytes,
    String id,
  ) async {
    final folder = (await directory()).path;
    final image = '$id.jpg';
    final thumbnail = '${id}_thumb.jpg';
    await File(p.join(folder, image)).writeAsBytes(bytes, flush: true);
    await Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('The image format is not supported.');
      }
      File(p.join(folder, thumbnail)).writeAsBytesSync(
        img.encodeJpg(
          _fit(img.bakeOrientation(decoded), _thumbnailSide),
          quality: _thumbnailQuality,
        ),
      );
    });
    return (image: image, thumbnail: thumbnail);
  }

  static img.Image _fit(img.Image image, int side) {
    if (image.width <= side && image.height <= side) return image;
    return image.width >= image.height
        ? img.copyResize(image, width: side)
        : img.copyResize(image, height: side);
  }
}
