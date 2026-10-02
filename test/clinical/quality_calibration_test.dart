// HU04, scenario 4: validator accuracy on 50 valid and 50 defective photos.
//
// Valid photos: assets/images/correct/valida_NN.jpg
// Defective photos: assets/images/incorrect/defectuosa_NN_<type>.jpg, where
// <type> is desenfoque, movimiento, oscura or sobreexpuesta.
// Phone photos (only reported): android/images/mobile example/good and bad.
//
// These folders are not bundled in the app: the pubspec only declares the
// files directly inside assets/images/. Run it with:
//
//   flutter test test/clinical/quality_calibration_test.dart
//
// A defective photo counts as detected when it is rejected or warned about,
// because in both cases the app does not analyze it without telling the
// user. A valid photo counts as accepted only when it gets no message at
// all. The report must state which set was used.
import 'dart:io';

import 'package:bov_mobile_app/clinical/domain/model/value_objects/image_quality.dart';
import 'package:bov_mobile_app/clinical/infrastructure/vision/computer_vision_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

const _validFolder = 'assets/images/correct';
const _defectiveFolder = 'assets/images/incorrect';
const _phoneFolder = 'android/images/mobile example';

/// Issue each defect type in the file name should trigger.
const _expectedIssue = {
  'desenfoque': ImageQualityIssue.blurry,
  'movimiento': ImageQualityIssue.blurry,
  'oscura': ImageQualityIssue.dark,
  'sobreexpuesta': ImageQualityIssue.overexposed,
};

List<File> _images(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) return [];
  return directory
      .listSync()
      .whereType<File>()
      .where(
        (f) => RegExp(r'\.(jpe?g|png)$', caseSensitive: false).hasMatch(f.path),
      )
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _name(File file) => file.uri.pathSegments.last;

String _defectType(File file) =>
    RegExp(r'_([a-z]+)\.\w+$').firstMatch(_name(file))?.group(1) ?? '?';

ImageQualityReport _assess(File file) =>
    ComputerVisionPreprocessor.processBytes(file.readAsBytesSync()).quality;

String _zone(ImageQualityReport report) => !report.isValid
    ? 'RECHAZO'
    : report.hasWarnings
    ? 'AVISO  '
    : 'OK     ';

bool _flagged(ImageQualityReport report) =>
    !report.isValid || report.hasWarnings;

String _percent(int part, int total) =>
    '$part/$total (${(part / total * 100).toStringAsFixed(1)} %)';

void main() {
  final valid = _images(_validFolder);
  final defective = _images(_defectiveFolder);

  test(
    'the validator accepts ≥95 % of valid photos and detects ≥90 % of '
    'defective ones',
    () {
      final lines = <String>[];

      var accepted = 0;
      for (final file in valid) {
        final report = _assess(file);
        if (!_flagged(report)) accepted++;
        lines.add('${_zone(report)} ${_name(file)}: $report');
      }

      var detected = 0;
      final byType = <String, (int detected, int rightReason, int total)>{};
      for (final file in defective) {
        final report = _assess(file);
        final type = _defectType(file);
        final found = [...report.issues, ...report.warnings];
        final rightReason = found.contains(_expectedIssue[type]);
        if (_flagged(report)) detected++;
        final (d, reason, total) = byType[type] ?? (0, 0, 0);
        byType[type] = (
          d + (_flagged(report) ? 1 : 0),
          reason + (rightReason ? 1 : 0),
          total + 1,
        );
        lines.add('${_zone(report)} ${_name(file)}: $report');
      }

      final summary = [
        'Valid accepted without messages: ${_percent(accepted, valid.length)}',
        'Defective detected: ${_percent(detected, defective.length)}',
        for (final MapEntry(key: type, value: (d, reason, total))
            in byType.entries)
          '  $type: detected ${_percent(d, total)}, '
              'right reason ${_percent(reason, total)}',
      ];
      // ignore: avoid_print
      print('${lines.join('\n')}\n\n${summary.join('\n')}');

      expect(accepted / valid.length, greaterThanOrEqualTo(0.95));
      expect(detected / defective.length, greaterThanOrEqualTo(0.90));
    },
    skip: valid.isEmpty || defective.isEmpty
        ? 'Add photos to $_validFolder and $_defectiveFolder'
        : false,
  );

  // Only printed: the phone set is small and mixes photo sources.
  test('phone photos report', () {
    final lines = [
      for (final folder in ['good', 'bad'])
        for (final file in _images('$_phoneFolder/$folder'))
          '${_zone(_assess(file))} $folder/${_name(file)}: '
              '${_assess(file)}',
    ];
    // ignore: avoid_print
    print(lines.join('\n'));
  }, skip: _images('$_phoneFolder/good').isEmpty ? 'No phone photos' : false);
}
