import 'package:uuid/uuid.dart';

import '../../../domain/model/aggregates/evaluation.dart';
import '../../../domain/model/value_objects/captured_image.dart';
import '../../../domain/model/value_objects/inference_result.dart';
import '../../../domain/repositories/evaluation_repository.dart';
import '../../../infrastructure/catalog/clinical_code_catalog.dart';
import '../../../infrastructure/storage/evaluation_image_store.dart';

/// Saves every analysis on the device as soon as its result is ready (HU10).
class EvaluationCommandService {
  final EvaluationRepository _repository;
  final EvaluationImageStore _images;
  final ClinicalCodeCatalog _codes;

  const EvaluationCommandService(this._repository, this._images, this._codes);

  /// Copies the photo to the app storage and saves the evaluation with its
  /// standard codes (HU07), pending of synchronization. Works the same
  /// without internet.
  Future<Evaluation> save(CapturedImage image, InferenceResult result) async {
    final uuid = const Uuid().v4();
    final files = await _images.store(image.path, uuid);
    return _repository.save(
      Evaluation(
        uuid: uuid,
        createdAt: DateTime.now(),
        imagePath: await _images.pathOf(files.image),
        thumbnailPath: await _images.pathOf(files.thumbnail),
        origin: image.origin,
        result: result,
        clinicalCodes: _codes.codesFor(result),
        catalogVersion: _codes.version,
      ),
    );
  }
}
