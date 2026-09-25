import 'package:flutter_test/flutter_test.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_colors.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';

void main() {
  test('El tema usa el verde principal del sistema de diseño', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.verdePrincipal);
  });
}