import '../model/aggregates/animal.dart';

/// An animal with the same ear tag is already registered (HU15, scenario 4).
class DuplicateEarTagException implements Exception {
  /// The registered animal, so the user can select it instead.
  final Animal existing;

  const DuplicateEarTagException(this.existing);

  @override
  String toString() =>
      'DuplicateEarTagException: ${existing.earTag} is already registered';
}
