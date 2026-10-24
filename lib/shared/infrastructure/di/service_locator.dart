import 'package:get_it/get_it.dart';

import '../../../clinical/application/internal/commandservices/evaluation_command_service.dart';
import '../../../clinical/domain/repositories/evaluation_repository.dart';
import '../../../clinical/infrastructure/persistence/isar/repositories/isar_evaluation_repository.dart';
import '../../../clinical/infrastructure/storage/evaluation_image_store.dart';
import '../persistence/isar/local_database.dart';

final locator = GetIt.instance;

/// Opens the local database and registers the services that use it.
Future<void> setUpServices() async {
  final isar = await LocalDatabase.open();
  final images = EvaluationImageStore();
  final evaluations = IsarEvaluationRepository(isar, images);
  locator
    ..registerSingleton<EvaluationRepository>(evaluations)
    ..registerSingleton(EvaluationCommandService(evaluations, images));
}
