import 'package:get_it/get_it.dart';

import '../../../clinical/application/internal/commandservices/evaluation_command_service.dart';
import '../../../clinical/application/internal/outboundservices/external_livestock_service.dart';
import '../../../clinical/domain/repositories/evaluation_repository.dart';
import '../../../clinical/infrastructure/catalog/clinical_code_catalog.dart';
import '../../../clinical/infrastructure/persistence/isar/repositories/isar_evaluation_repository.dart';
import '../../../clinical/infrastructure/storage/evaluation_image_store.dart';
import '../../../livestock/application/internal/commandservices/animal_command_service.dart';
import '../../../livestock/application/internal/queryservices/animal_query_service.dart';
import '../../../livestock/infrastructure/persistence/isar/repositories/isar_animal_repository.dart';
import '../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../persistence/isar/local_database.dart';

final locator = GetIt.instance;

/// Opens the local database, loads the code catalog and registers the
/// services of each bounded context.
Future<void> setUpServices() async {
  final isar = await LocalDatabase.open();
  final codes = await ClinicalCodeCatalog.load();

  // Livestock (HU15).
  final animals = IsarAnimalRepository(isar);
  final livestock = LivestockContextFacade(
    AnimalCommandService(animals),
    AnimalQueryService(animals),
  );

  // Clinical (HU07, HU10, HU11).
  final images = EvaluationImageStore();
  final evaluations = IsarEvaluationRepository(isar, images);
  locator
    ..registerSingleton(codes)
    ..registerSingleton(livestock)
    ..registerSingleton<EvaluationRepository>(evaluations)
    ..registerSingleton(
      EvaluationCommandService(
        evaluations,
        images,
        codes,
        ExternalLivestockService(livestock),
      ),
    );
}
