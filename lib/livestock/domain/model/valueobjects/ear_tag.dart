/// Ear tag number that identifies an animal of the farm (HU15).
///
/// It is stored without spaces and in upper case, so "pe 0012" and "PE0012"
/// are the same tag.
class EarTag {
  static const maxLength = 20;
  static final _allowed = RegExp(r'^[A-Z0-9-]+$');

  final String value;

  const EarTag._(this.value);

  /// Normalizes [text]; throws [FormatException] when it is not valid.
  factory EarTag(String text) {
    final value = normalize(text);
    final error = validate(value);
    if (error != null) throw FormatException(error);
    return EarTag._(value);
  }

  static String normalize(String text) =>
      text.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  /// Message for the user, or null when the normalized [value] is valid.
  static String? validate(String value) {
    if (value.isEmpty) return 'Ingrese el número de arete.';
    if (value.length > maxLength) {
      return 'El arete tiene como máximo $maxLength caracteres.';
    }
    if (!_allowed.hasMatch(value)) {
      return 'Use solo letras, números y guiones.';
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is EarTag && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
