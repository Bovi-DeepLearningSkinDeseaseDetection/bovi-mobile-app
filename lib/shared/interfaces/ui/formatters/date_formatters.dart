/// Dates as the farmer reads them, without depending on the device locale.
class DateFormatters {
  DateFormatters._();

  /// Day, for example "24/10/2026".
  static String day(DateTime date) =>
      '${_two(date.day)}/${_two(date.month)}/${date.year}';

  /// Day and time, for example "24/10/2026 · 10:35".
  static String dayAndTime(DateTime date) =>
      '${day(date)} · ${_two(date.hour)}:${_two(date.minute)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
