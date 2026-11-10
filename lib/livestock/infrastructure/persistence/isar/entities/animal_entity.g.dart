// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAnimalEntityCollection on Isar {
  IsarCollection<AnimalEntity> get animals => this.collection();
}

const AnimalEntitySchema = CollectionSchema(
  name: r'animals',
  id: -5474818206393984653,
  properties: {
    r'breed': PropertySchema(id: 0, name: r'breed', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'earTag': PropertySchema(id: 2, name: r'earTag', type: IsarType.string),
    r'lastEvaluatedAt': PropertySchema(
      id: 3,
      name: r'lastEvaluatedAt',
      type: IsarType.dateTime,
    ),
    r'sex': PropertySchema(
      id: 4,
      name: r'sex',
      type: IsarType.string,
      enumMap: _AnimalEntitysexEnumValueMap,
    ),
    r'syncStatus': PropertySchema(
      id: 5,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _AnimalEntitysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(id: 7, name: r'uuid', type: IsarType.string),
  },

  estimateSize: _animalEntityEstimateSize,
  serialize: _animalEntitySerialize,
  deserialize: _animalEntityDeserialize,
  deserializeProp: _animalEntityDeserializeProp,
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
    r'earTag': IndexSchema(
      id: 29730451327187620,
      name: r'earTag',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'earTag',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'lastEvaluatedAt': IndexSchema(
      id: -513909677624340809,
      name: r'lastEvaluatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastEvaluatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _animalEntityGetId,
  getLinks: _animalEntityGetLinks,
  attach: _animalEntityAttach,
  version: '3.4.1',
);

int _animalEntityEstimateSize(
  AnimalEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breed.length * 3;
  bytesCount += 3 + object.earTag.length * 3;
  bytesCount += 3 + object.sex.name.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _animalEntitySerialize(
  AnimalEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.breed);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.earTag);
  writer.writeDateTime(offsets[3], object.lastEvaluatedAt);
  writer.writeString(offsets[4], object.sex.name);
  writer.writeString(offsets[5], object.syncStatus.name);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeString(offsets[7], object.uuid);
}

AnimalEntity _animalEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnimalEntity();
  object.breed = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.earTag = reader.readString(offsets[2]);
  object.id = id;
  object.lastEvaluatedAt = reader.readDateTimeOrNull(offsets[3]);
  object.sex =
      _AnimalEntitysexValueEnumMap[reader.readStringOrNull(offsets[4])] ??
      AnimalSex.female;
  object.syncStatus =
      _AnimalEntitysyncStatusValueEnumMap[reader.readStringOrNull(
        offsets[5],
      )] ??
      SyncStatus.pending;
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.uuid = reader.readString(offsets[7]);
  return object;
}

P _animalEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (_AnimalEntitysexValueEnumMap[reader.readStringOrNull(offset)] ??
              AnimalSex.female)
          as P;
    case 5:
      return (_AnimalEntitysyncStatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SyncStatus.pending)
          as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AnimalEntitysexEnumValueMap = {r'female': r'female', r'male': r'male'};
const _AnimalEntitysexValueEnumMap = {
  r'female': AnimalSex.female,
  r'male': AnimalSex.male,
};
const _AnimalEntitysyncStatusEnumValueMap = {
  r'pending': r'pending',
  r'synced': r'synced',
  r'failed': r'failed',
};
const _AnimalEntitysyncStatusValueEnumMap = {
  r'pending': SyncStatus.pending,
  r'synced': SyncStatus.synced,
  r'failed': SyncStatus.failed,
};

Id _animalEntityGetId(AnimalEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _animalEntityGetLinks(AnimalEntity object) {
  return [];
}

void _animalEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AnimalEntity object,
) {
  object.id = id;
}

extension AnimalEntityByIndex on IsarCollection<AnimalEntity> {
  Future<AnimalEntity?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  AnimalEntity? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<AnimalEntity?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<AnimalEntity?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(AnimalEntity object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(AnimalEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<AnimalEntity> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(
    List<AnimalEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }

  Future<AnimalEntity?> getByEarTag(String earTag) {
    return getByIndex(r'earTag', [earTag]);
  }

  AnimalEntity? getByEarTagSync(String earTag) {
    return getByIndexSync(r'earTag', [earTag]);
  }

  Future<bool> deleteByEarTag(String earTag) {
    return deleteByIndex(r'earTag', [earTag]);
  }

  bool deleteByEarTagSync(String earTag) {
    return deleteByIndexSync(r'earTag', [earTag]);
  }

  Future<List<AnimalEntity?>> getAllByEarTag(List<String> earTagValues) {
    final values = earTagValues.map((e) => [e]).toList();
    return getAllByIndex(r'earTag', values);
  }

  List<AnimalEntity?> getAllByEarTagSync(List<String> earTagValues) {
    final values = earTagValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'earTag', values);
  }

  Future<int> deleteAllByEarTag(List<String> earTagValues) {
    final values = earTagValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'earTag', values);
  }

  int deleteAllByEarTagSync(List<String> earTagValues) {
    final values = earTagValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'earTag', values);
  }

  Future<Id> putByEarTag(AnimalEntity object) {
    return putByIndex(r'earTag', object);
  }

  Id putByEarTagSync(AnimalEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'earTag', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEarTag(List<AnimalEntity> objects) {
    return putAllByIndex(r'earTag', objects);
  }

  List<Id> putAllByEarTagSync(
    List<AnimalEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'earTag', objects, saveLinks: saveLinks);
  }
}

extension AnimalEntityQueryWhereSort
    on QueryBuilder<AnimalEntity, AnimalEntity, QWhere> {
  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhere> anyLastEvaluatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastEvaluatedAt'),
      );
    });
  }
}

extension AnimalEntityQueryWhere
    on QueryBuilder<AnimalEntity, AnimalEntity, QWhereClause> {
  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> uuidEqualTo(
    String uuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'uuid', value: [uuid]),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> uuidNotEqualTo(
    String uuid,
  ) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> earTagEqualTo(
    String earTag,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'earTag', value: [earTag]),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause> earTagNotEqualTo(
    String earTag,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'earTag',
                lower: [],
                upper: [earTag],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'earTag',
                lower: [earTag],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'earTag',
                lower: [earTag],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'earTag',
                lower: [],
                upper: [earTag],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'lastEvaluatedAt', value: [null]),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastEvaluatedAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtEqualTo(DateTime? lastEvaluatedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'lastEvaluatedAt',
          value: [lastEvaluatedAt],
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtNotEqualTo(DateTime? lastEvaluatedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastEvaluatedAt',
                lower: [],
                upper: [lastEvaluatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastEvaluatedAt',
                lower: [lastEvaluatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastEvaluatedAt',
                lower: [lastEvaluatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'lastEvaluatedAt',
                lower: [],
                upper: [lastEvaluatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtGreaterThan(
    DateTime? lastEvaluatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastEvaluatedAt',
          lower: [lastEvaluatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtLessThan(DateTime? lastEvaluatedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastEvaluatedAt',
          lower: [],
          upper: [lastEvaluatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterWhereClause>
  lastEvaluatedAtBetween(
    DateTime? lowerLastEvaluatedAt,
    DateTime? upperLastEvaluatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'lastEvaluatedAt',
          lower: [lowerLastEvaluatedAt],
          includeLower: includeLower,
          upper: [upperLastEvaluatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AnimalEntityQueryFilter
    on QueryBuilder<AnimalEntity, AnimalEntity, QFilterCondition> {
  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  breedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'breed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  breedStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'breed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> breedMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'breed',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  breedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'breed', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  breedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'breed', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> earTagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> earTagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'earTag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'earTag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> earTagMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'earTag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'earTag', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  earTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'earTag', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastEvaluatedAt'),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastEvaluatedAt'),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastEvaluatedAt', value: value),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastEvaluatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastEvaluatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  lastEvaluatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastEvaluatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexEqualTo(
    AnimalSex value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  sexGreaterThan(
    AnimalSex value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexLessThan(
    AnimalSex value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexBetween(
    AnimalSex lower,
    AnimalSex upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sex',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> sexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sex', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  sexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sex', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncStatus', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition> uuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uuid', value: ''),
      );
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterFilterCondition>
  uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'uuid', value: ''),
      );
    });
  }
}

extension AnimalEntityQueryObject
    on QueryBuilder<AnimalEntity, AnimalEntity, QFilterCondition> {}

extension AnimalEntityQueryLinks
    on QueryBuilder<AnimalEntity, AnimalEntity, QFilterCondition> {}

extension AnimalEntityQuerySortBy
    on QueryBuilder<AnimalEntity, AnimalEntity, QSortBy> {
  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByEarTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTag', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByEarTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTag', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  sortByLastEvaluatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEvaluatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  sortByLastEvaluatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEvaluatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension AnimalEntityQuerySortThenBy
    on QueryBuilder<AnimalEntity, AnimalEntity, QSortThenBy> {
  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByEarTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTag', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByEarTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earTag', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  thenByLastEvaluatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEvaluatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  thenByLastEvaluatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEvaluatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenBySex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenBySexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sex', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy>
  thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension AnimalEntityQueryWhereDistinct
    on QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> {
  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctByBreed({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctByEarTag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct>
  distinctByLastEvaluatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEvaluatedAt');
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctBySex({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctBySyncStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<AnimalEntity, AnimalEntity, QDistinct> distinctByUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension AnimalEntityQueryProperty
    on QueryBuilder<AnimalEntity, AnimalEntity, QQueryProperty> {
  QueryBuilder<AnimalEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnimalEntity, String, QQueryOperations> breedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breed');
    });
  }

  QueryBuilder<AnimalEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AnimalEntity, String, QQueryOperations> earTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earTag');
    });
  }

  QueryBuilder<AnimalEntity, DateTime?, QQueryOperations>
  lastEvaluatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEvaluatedAt');
    });
  }

  QueryBuilder<AnimalEntity, AnimalSex, QQueryOperations> sexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sex');
    });
  }

  QueryBuilder<AnimalEntity, SyncStatus, QQueryOperations>
  syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<AnimalEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<AnimalEntity, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
