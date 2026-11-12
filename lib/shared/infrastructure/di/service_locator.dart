import 'package:get_it/get_it.dart';

import '../../../clinical/application/internal/commandservices/cloud_sync_service.dart';
import '../../../clinical/application/internal/commandservices/evaluation_command_service.dart';
import '../../../clinical/application/internal/commandservices/history_restore_service.dart';
import '../../../clinical/application/internal/outboundservices/external_iam_service.dart'
    as clinical_iam;
import '../../../clinical/application/internal/outboundservices/external_livestock_service.dart';
import '../../../clinical/domain/repositories/evaluation_repository.dart';
import '../../../clinical/domain/repositories/evaluation_sync_repository.dart';
import '../../../clinical/infrastructure/catalog/clinical_code_catalog.dart';
import '../../../clinical/infrastructure/catalog/disease_sheet_catalog.dart';
import '../../../clinical/infrastructure/http/evaluation_sync_http_gateway.dart';
import '../../../clinical/infrastructure/http/history_restore_http_gateway.dart';
import '../../../clinical/infrastructure/persistence/isar/repositories/isar_evaluation_repository.dart';
import '../../../clinical/infrastructure/storage/evaluation_image_store.dart';
import '../../../iam/application/internal/commandservices/auth_command_service.dart';
import '../../../iam/infrastructure/http/auth_http_gateway.dart';
import '../../../iam/infrastructure/storage/secure/secure_session_repository.dart';
import '../../../iam/interfaces/acl/iam_context_facade.dart';
import '../../../livestock/application/internal/commandservices/animal_command_service.dart';
import '../../../livestock/application/internal/commandservices/animal_restore_service.dart';
import '../../../livestock/application/internal/commandservices/animal_sync_service.dart';
import '../../../livestock/application/internal/outboundservices/external_iam_service.dart'
    as livestock_iam;
import '../../../livestock/application/internal/queryservices/animal_query_service.dart';
import '../../../livestock/infrastructure/http/animal_restore_http_gateway.dart';
import '../../../livestock/infrastructure/http/animal_sync_http_gateway.dart';
import '../../../livestock/infrastructure/persistence/isar/repositories/isar_animal_repository.dart';
import '../../../livestock/interfaces/acl/livestock_context_facade.dart';
import '../network/api_client.dart';
import '../network/connectivity_monitor.dart';
import '../persistence/isar/local_database.dart';

final locator = GetIt.instance;

/// Opens the local database, loads the code catalog and registers the
/// services of each bounded context. Safe to call again: the background
/// sync (WorkManager) calls it in its own isolate.
Future<void> setUpServices() async {
  if (locator.isRegistered<CloudSyncService>()) return;
  final isar = await LocalDatabase.open();
  final codes = await ClinicalCodeCatalog.load();
  final sheets = await DiseaseSheetCatalog.load();

  // IAM (HU14): one HTTP client for the whole app.
  final api = createApiClient();
  final auth = AuthCommandService(
    AuthHttpGateway(api),
    SecureSessionRepository(),
  );
  final iam = IamContextFacade(auth);

  // Livestock (HU15) and the sync of its animals (HU12).
  final animals = IsarAnimalRepository(isar);
  final livestock = LivestockContextFacade(
    AnimalCommandService(animals, livestock_iam.ExternalIamService(iam)),
    AnimalQueryService(animals),
    AnimalSyncService(animals, AnimalSyncHttpGateway(api)),
    AnimalRestoreService(animals, AnimalRestoreHttpGateway(api)),
  );

  // Clinical (HU07, HU10, HU11) and the cloud sync (HU12).
  final images = EvaluationImageStore();
  final evaluations = IsarEvaluationRepository(isar, images);
  final clinicalIam = clinical_iam.ExternalIamService(iam);
  locator
    ..registerSingleton(api)
    ..registerSingleton(auth)
    ..registerSingleton(iam)
    ..registerSingleton(codes)
    ..registerSingleton(sheets)
    ..registerSingleton(livestock)
    ..registerSingleton(ConnectivityMonitor())
    ..registerSingleton<EvaluationRepository>(evaluations)
    ..registerSingleton<EvaluationSyncRepository>(evaluations)
    ..registerSingleton(
      EvaluationCommandService(
        evaluations,
        images,
        codes,
        ExternalLivestockService(livestock),
        clinicalIam,
      ),
    )
    ..registerSingleton(
      HistoryRestoreService(
        evaluations,
        evaluations,
        HistoryRestoreHttpGateway(api),
        images,
        clinicalIam,
        livestock,
      ),
    )
    ..registerSingleton(
      CloudSyncService(
        evaluations,
        EvaluationSyncHttpGateway(api),
        clinicalIam,
        livestock,
      ),
    );
}
