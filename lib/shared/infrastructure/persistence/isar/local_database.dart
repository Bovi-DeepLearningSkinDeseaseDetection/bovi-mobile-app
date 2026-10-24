import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../clinical/infrastructure/persistence/isar/entities/evaluation_entity.dart';
import '../../../../livestock/infrastructure/persistence/isar/entities/animal_entity.dart';

/// The Isar database of the device, shared by every bounded context.
class LocalDatabase {
  LocalDatabase._();

  static const name = 'bovi';

  static Future<Isar> open() async {
    final existing = Isar.getInstance(name);
    if (existing != null) return existing;
    final directory = await getApplicationDocumentsDirectory();
    return Isar.open(
      [EvaluationEntitySchema, AnimalEntitySchema],
      directory: directory.path,
      name: name,
    );
  }
}
