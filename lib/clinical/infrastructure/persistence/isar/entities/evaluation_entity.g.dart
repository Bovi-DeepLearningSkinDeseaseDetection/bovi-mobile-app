// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetEvaluationEntityCollection on Isar {
  IsarCollection<EvaluationEntity> get evaluations => this.collection();
}

const EvaluationEntitySchema = CollectionSchema(
  name: r'evaluations',
  id: 597215722459527171,
  properties: {
    r'animalEarTag': PropertySchema(
      id: 0,
      name: r'animalEarTag',
      type: IsarType.string,
    ),
    r'animalId': PropertySchema(id: 1, name: r'animalId', type: IsarType.long),
    r'bodyZone': PropertySchema(
      id: 2,
      name: r'bodyZone',
      type: IsarType.string,
      enumMap: _EvaluationEntitybodyZoneEnumValueMap,
    ),
    r'confidence': PropertySchema(
      id: 3,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'imageFile': PropertySchema(
      id: 5,
      name: r'imageFile',
      type: IsarType.string,
    ),
    r'inferenceMs': PropertySchema(
      id: 6,
      name: r'inferenceMs',
      type: IsarType.long,
    ),
    r'modelVersion': PropertySchema(
      id: 7,
      name: r'modelVersion',
      type: IsarType.string,
    ),
    r'origin': PropertySchema(
      id: 8,
      name: r'origin',
      type: IsarType.string,
      enumMap: _EvaluationEntityoriginEnumValueMap,
    ),
    r'outcome': PropertySchema(
      id: 9,
      name: r'outcome',
      type: IsarType.string,
      enumMap: _EvaluationEntityoutcomeEnumValueMap,
    ),
    r'probabilities': PropertySchema(
      id: 10,
      name: r'probabilities',
      type: IsarType.objectList,

      target: r'ClassScoreEmbedded',
    ),
    r'syncStatus': PropertySchema(
      id: 11,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _EvaluationEntitysyncStatusEnumValueMap,
    ),
    r'syncedAt': PropertySchema(
      id: 12,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'thumbnailFile': PropertySchema(
      id: 13,
      name: r'thumbnailFile',
      type: IsarType.string,
    ),
    r'topLabel': PropertySchema(
      id: 14,
      name: r'topLabel',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 16, name: r'uuid', type: IsarType.string),
    r'venomCode': PropertySchema(
      id: 17,
      name: r'venomCode',
      type: IsarType.string,
    ),
  },

  estimateSize: _evaluationEntityEstimateSize,
  serialize: _evaluationEntitySerialize,
  deserialize: _evaluationEntityDeserialize,
  deserializeProp: _evaluationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'outcome': IndexSchema(
      id: -2278321333017941260,
      name: r'outcome',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'outcome',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'topLabel': IndexSchema(
      id: -6224614633042454302,
      name: r'topLabel',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topLabel',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'animalId': IndexSchema(
      id: -8446297297210463032,
      name: r'animalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'animalEarTag': IndexSchema(
      id: -5470590513089947165,
      name: r'animalEarTag',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalEarTag',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'ClassScoreEmbedded': ClassScoreEmbeddedSchema},

  getId: _evaluationEntityGetId,
  getLinks: _evaluationEntityGetLinks,
  attach: _evaluationEntityAttach,
  version: '3.4.1',
);

int _evaluationEntityEstimateSize(
  EvaluationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animalEarTag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.bodyZone;
    if (value != null) {
      bytesCount += 3 + value.name.length * 3;
    }
  }
  bytesCount += 3 + object.imageFile.length * 3;
  bytesCount += 3 + object.modelVersion.length * 3;
  bytesCount += 3 + object.origin.name.length * 3;
  bytesCount += 3 + object.outcome.name.length * 3;
  bytesCount += 3 + object.probabilities.length * 3;
  {
    final offsets = allOffsets[ClassScoreEmbedded]!;
    for (var i = 0; i < object.probabilities.length; i++) {
      final value = object.probabilities[i];
      bytesCount += ClassScoreEmbeddedSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.syncStatus.name.length * 3;
  bytesCount += 3 + object.thumbnailFile.length * 3;
  bytesCount += 3 + object.topLabel.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.venomCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _evaluationEntitySerialize(
  EvaluationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalEarTag);
  writer.writeLong(offsets[1], object.animalId);
  writer.writeString(offsets[2], object.bodyZone?.name);
  writer.writeDouble(offsets[3], object.confidence);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeString(offsets[5], object.imageFile);
  writer.writeLong(offsets[6], object.inferenceMs);
  writer.writeString(offsets[7], object.modelVersion);
  writer.writeString(offsets[8], object.origin.name);
  writer.writeString(offsets[9], object.outcome.name);
  writer.writeObjectList<ClassScoreEmbedded>(
    offsets[10],
    allOffsets,
    ClassScoreEmbeddedSchema.serialize,
    object.probabilities,
  );
  writer.writeString(offsets[11], object.syncStatus.name);
  writer.writeDateTime(offsets[12], object.syncedAt);
  writer.writeString(offsets[13], object.thumbnailFile);
  writer.writeString(offsets[14], object.topLabel);
  writer.writeDateTime(offsets[15], object.updatedAt);
  writer.writeString(offsets[16], object.uuid);
  writer.writeString(offsets[17], object.venomCode);
}

EvaluationEntity _evaluationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EvaluationEntity();
  object.animalEarTag = reader.readStringOrNull(offsets[0]);
  object.animalId = reader.readLongOrNull(offsets[1]);
  object.bodyZone =
      _EvaluationEntitybodyZoneValueEnumMap[reader.readStringOrNull(
        offsets[2],
      )];
  object.confidence = reader.readDouble(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.id = id;
  object.imageFile = reader.readString(offsets[5]);
  object.inferenceMs = reader.readLong(offsets[6]);
  object.modelVersion = reader.readString(offsets[7]);
  object.origin =
      _EvaluationEntityoriginValueEnumMap[reader.readStringOrNull(
        offsets[8],
      )] ??
      ImageOrigin.camera;
  object.outcome =
      _EvaluationEntityoutcomeValueEnumMap[reader.readStringOrNull(
        offsets[9],
      )] ??
      EvaluationOutcome.healthy;
  object.probabilities =
      reader.readObjectList<ClassScoreEmbedded>(
        offsets[10],
        ClassScoreEmbeddedSchema.deserialize,
        allOffsets,
        ClassScoreEmbedded(),
      ) ??
      [];
  object.syncStatus =
      _EvaluationEntitysyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[11],
      )] ??
      SyncStatus.pending;
  object.syncedAt = reader.readDateTimeOrNull(offsets[12]);
  object.thumbnailFile = reader.readString(offsets[13]);
  object.topLabel = reader.readString(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  object.uuid = reader.readString(offsets[16]);
  object.venomCode = reader.readStringOrNull(offsets[17]);
  return object;
}

P _evaluationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (_EvaluationEntitybodyZoneValueEnumMap[reader.readStringOrNull(
            offset,
          )])
          as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_EvaluationEntityoriginValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              ImageOrigin.camera)
          as P;
    case 9:
      return (_EvaluationEntityoutcomeValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              EvaluationOutcome.healthy)
          as P;
    case 10:
      return (reader.readObjectList<ClassScoreEmbedded>(
                offset,
                ClassScoreEmbeddedSchema.deserialize,
                allOffsets,
                ClassScoreEmbedded(),
              ) ??
              [])
          as P;
    case 11:
      return (_EvaluationEntitysyncStatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SyncStatus.pending)
          as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EvaluationEntitybodyZoneEnumValueMap = {
  r'head': r'head',
  r'neck': r'neck',
  r'back': r'back',
  r'flank': r'flank',
  r'legs': r'legs',
  r'udder': r'udder',
  r'other': r'other',
};
const _EvaluationEntitybodyZoneValueEnumMap = {
  r'head': BodyZone.head,
  r'neck': BodyZone.neck,
  r'back': BodyZone.back,
  r'flank': BodyZone.flank,
  r'legs': BodyZone.legs,
  r'udder': BodyZone.udder,
  r'other': BodyZone.other,
};
const _EvaluationEntityoriginEnumValueMap = {
  r'camera': r'camera',
  r'gallery': r'gallery',
};
const _EvaluationEntityoriginValueEnumMap = {
  r'camera': ImageOrigin.camera,
  r'gallery': ImageOrigin.gallery,
};
const _EvaluationEntityoutcomeEnumValueMap = {
  r'healthy': r'healthy',
  r'lesion': r'lesion',
  r'inconclusive': r'inconclusive',
};
const _EvaluationEntityoutcomeValueEnumMap = {
  r'healthy': EvaluationOutcome.healthy,
  r'lesion': EvaluationOutcome.lesion,
  r'inconclusive': EvaluationOutcome.inconclusive,
};
const _EvaluationEntitysyncStatusEnumValueMap = {
  r'pending': r'pending',
  r'synced': r'synced',
  r'failed': r'failed',
};
const _EvaluationEntitysyncStatusValueEnumMap = {
  r'pending': SyncStatus.pending,
  r'synced': SyncStatus.synced,
  r'failed': SyncStatus.failed,
};

Id _evaluationEntityGetId(EvaluationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _evaluationEntityGetLinks(EvaluationEntity object) {
  return [];
}

void _evaluationEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  EvaluationEntity object,
) {
  object.id = id;
}

extension EvaluationEntityByIndex on IsarCollection<EvaluationEntity> {
  Future<EvaluationEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  EvaluationEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<EvaluationEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<EvaluationEntity?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(EvaluationEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(EvaluationEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<EvaluationEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<EvaluationEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension EvaluationEntityQueryWhereSort
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QWhere> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhere> anyAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'animalId'),
      );
    });
  }
}

extension EvaluationEntityQueryWhere
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QWhereClause> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [uuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'uuid',
                lower: [],
                upper: [uuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  createdAtGreaterThan(DateTime createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  createdAtLessThan(DateTime createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  outcomeEqualTo(EvaluationOutcome outcome) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'outcome', value: [outcome]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  outcomeNotEqualTo(EvaluationOutcome outcome) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'outcome',
                lower: [],
                upper: [outcome],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'outcome',
                lower: [outcome],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'outcome',
                lower: [outcome],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'outcome',
                lower: [],
                upper: [outcome],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  topLabelEqualTo(String topLabel) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'topLabel', value: [topLabel]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  topLabelNotEqualTo(String topLabel) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topLabel',
                lower: [],
                upper: [topLabel],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topLabel',
                lower: [topLabel],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topLabel',
                lower: [topLabel],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'topLabel',
                lower: [],
                upper: [topLabel],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalId', value: [null]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdEqualTo(int? animalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalId', value: [animalId]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdNotEqualTo(int? animalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [],
                upper: [animalId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [animalId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [animalId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalId',
                lower: [],
                upper: [animalId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdGreaterThan(int? animalId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalId',
          lower: [animalId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdLessThan(int? animalId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalId',
          lower: [],
          upper: [animalId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalIdBetween(
    int? lowerAnimalId,
    int? upperAnimalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalId',
          lower: [lowerAnimalId],
          includeLower: includeLower,
          upper: [upperAnimalId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalEarTagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'animalEarTag', value: [null]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalEarTagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'animalEarTag',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalEarTagEqualTo(String? animalEarTag) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'animalEarTag',
          value: [animalEarTag],
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  animalEarTagNotEqualTo(String? animalEarTag) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalEarTag',
                lower: [],
                upper: [animalEarTag],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalEarTag',
                lower: [animalEarTag],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalEarTag',
                lower: [animalEarTag],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'animalEarTag',
                lower: [],
                upper: [animalEarTag],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  syncStatusEqualTo(SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncStatus', value: [syncStatus]),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterWhereClause>
  syncStatusNotEqualTo(SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [],
                upper: [syncStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [syncStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [syncStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatus',
                lower: [],
                upper: [syncStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EvaluationEntityQueryFilter
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QFilterCondition> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'animalEarTag'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'animalEarTag'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animalEarTag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'animalEarTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'animalEarTag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animalEarTag', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalEarTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'animalEarTag', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'animalId'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'animalId'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'animalId', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'animalId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'animalId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  animalIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'animalId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bodyZone'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bodyZone'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneEqualTo(BodyZone? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneGreaterThan(
    BodyZone? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneLessThan(
    BodyZone? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneBetween(
    BodyZone? lower,
    BodyZone? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bodyZone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bodyZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bodyZone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bodyZone', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  bodyZoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bodyZone', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  confidenceEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'confidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'confidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'confidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'confidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'imageFile',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'imageFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'imageFile',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'imageFile', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  imageFileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'imageFile', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  inferenceMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inferenceMs', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  inferenceMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inferenceMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  inferenceMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inferenceMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  inferenceMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inferenceMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'modelVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'modelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'modelVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'modelVersion', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  modelVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'modelVersion', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originEqualTo(ImageOrigin value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originGreaterThan(
    ImageOrigin value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originLessThan(
    ImageOrigin value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originBetween(
    ImageOrigin lower,
    ImageOrigin upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'origin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'origin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'origin',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'origin', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  originIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'origin', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeEqualTo(EvaluationOutcome value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeGreaterThan(
    EvaluationOutcome value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeLessThan(
    EvaluationOutcome value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeBetween(
    EvaluationOutcome lower,
    EvaluationOutcome upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outcome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outcome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  outcomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'probabilities', length, true, length, true);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'probabilities', 0, true, 0, true);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'probabilities', 0, false, 999999, true);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'probabilities', 0, true, length, include);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'probabilities', length, include, 999999, true);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'probabilities',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusEqualTo(SyncStatus value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusGreaterThan(
    SyncStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusLessThan(
    SyncStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusBetween(
    SyncStatus lower,
    SyncStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syncStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syncStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncedAt'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncedAt'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncedAt', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnailFile',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnailFile',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnailFile',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnailFile', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  thumbnailFileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnailFile', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'topLabel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'topLabel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'topLabel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'topLabel', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  topLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'topLabel', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'uuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'uuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'venomCode'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'venomCode'),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'venomCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'venomCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'venomCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'venomCode', value: ''),
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  venomCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'venomCode', value: ''),
      );
    });
  }
}

extension EvaluationEntityQueryObject
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QFilterCondition> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterFilterCondition>
  probabilitiesElement(FilterQuery<ClassScoreEmbedded> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'probabilities');
    });
  }
}

extension EvaluationEntityQueryLinks
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QFilterCondition> {}

extension EvaluationEntityQuerySortBy
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QSortBy> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByAnimalEarTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalEarTag', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByAnimalEarTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalEarTag', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByBodyZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyZone', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByBodyZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyZone', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByImageFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageFile', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByImageFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageFile', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByInferenceMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceMs', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByInferenceMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceMs', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelVersion', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelVersion', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByThumbnailFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailFile', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByThumbnailFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailFile', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByTopLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topLabel', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByTopLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topLabel', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByVenomCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'venomCode', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  sortByVenomCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'venomCode', Sort.desc);
    });
  }
}

extension EvaluationEntityQuerySortThenBy
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QSortThenBy> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByAnimalEarTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalEarTag', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByAnimalEarTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalEarTag', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByBodyZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyZone', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByBodyZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyZone', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByImageFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageFile', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByImageFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageFile', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByInferenceMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceMs', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByInferenceMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inferenceMs', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelVersion', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modelVersion', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByThumbnailFile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailFile', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByThumbnailFileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailFile', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByTopLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topLabel', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByTopLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topLabel', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByVenomCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'venomCode', Sort.asc);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QAfterSortBy>
  thenByVenomCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'venomCode', Sort.desc);
    });
  }
}

extension EvaluationEntityQueryWhereDistinct
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct> {
  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByAnimalEarTag({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalEarTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalId');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByBodyZone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyZone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByImageFile({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageFile', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByInferenceMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inferenceMs');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByModelVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modelVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct> distinctByOrigin({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByOutcome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByThumbnailFile({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'thumbnailFile',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByTopLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationEntity, QDistinct>
  distinctByVenomCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'venomCode', caseSensitive: caseSensitive);
    });
  }
}

extension EvaluationEntityQueryProperty
    on QueryBuilder<EvaluationEntity, EvaluationEntity, QQueryProperty> {
  QueryBuilder<EvaluationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EvaluationEntity, String?, QQueryOperations>
  animalEarTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalEarTag');
    });
  }

  QueryBuilder<EvaluationEntity, int?, QQueryOperations> animalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalId');
    });
  }

  QueryBuilder<EvaluationEntity, BodyZone?, QQueryOperations>
  bodyZoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyZone');
    });
  }

  QueryBuilder<EvaluationEntity, double, QQueryOperations>
  confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<EvaluationEntity, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<EvaluationEntity, String, QQueryOperations> imageFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageFile');
    });
  }

  QueryBuilder<EvaluationEntity, int, QQueryOperations> inferenceMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inferenceMs');
    });
  }

  QueryBuilder<EvaluationEntity, String, QQueryOperations>
  modelVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modelVersion');
    });
  }

  QueryBuilder<EvaluationEntity, ImageOrigin, QQueryOperations>
  originProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origin');
    });
  }

  QueryBuilder<EvaluationEntity, EvaluationOutcome, QQueryOperations>
  outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<EvaluationEntity, List<ClassScoreEmbedded>, QQueryOperations>
  probabilitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'probabilities');
    });
  }

  QueryBuilder<EvaluationEntity, SyncStatus, QQueryOperations>
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<EvaluationEntity, DateTime?, QQueryOperations>
  syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<EvaluationEntity, String, QQueryOperations>
  thumbnailFileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailFile');
    });
  }

  QueryBuilder<EvaluationEntity, String, QQueryOperations> topLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topLabel');
    });
  }

  QueryBuilder<EvaluationEntity, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<EvaluationEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<EvaluationEntity, String?, QQueryOperations>
  venomCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'venomCode');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

const ClassScoreEmbeddedSchema = Schema(
  name: r'ClassScoreEmbedded',
  id: -4165843112048175741,
  properties: {
    r'label': PropertySchema(id: 0, name: r'label', type: IsarType.string),
    r'probability': PropertySchema(
      id: 1,
      name: r'probability',
      type: IsarType.double,
    ),
  },

  estimateSize: _classScoreEmbeddedEstimateSize,
  serialize: _classScoreEmbeddedSerialize,
  deserialize: _classScoreEmbeddedDeserialize,
  deserializeProp: _classScoreEmbeddedDeserializeProp,
);

int _classScoreEmbeddedEstimateSize(
  ClassScoreEmbedded object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  return bytesCount;
}

void _classScoreEmbeddedSerialize(
  ClassScoreEmbedded object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.label);
  writer.writeDouble(offsets[1], object.probability);
}

ClassScoreEmbedded _classScoreEmbeddedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassScoreEmbedded();
  object.label = reader.readString(offsets[0]);
  object.probability = reader.readDouble(offsets[1]);
  return object;
}

P _classScoreEmbeddedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ClassScoreEmbeddedQueryFilter
    on QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QFilterCondition> {
  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  probabilityEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'probability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  probabilityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'probability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  probabilityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'probability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QAfterFilterCondition>
  probabilityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'probability',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension ClassScoreEmbeddedQueryObject
    on QueryBuilder<ClassScoreEmbedded, ClassScoreEmbedded, QFilterCondition> {}
