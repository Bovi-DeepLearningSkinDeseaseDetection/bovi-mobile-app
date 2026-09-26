import 'package:flutter_test/flutter_test.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_colors.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/marco_guia.dart';

void main() {
  test('El tema usa el verde principal del sistema de diseño', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.verdePrincipal);
  });
  testWidgets('La guía muestra el texto de encuadre (HU03)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MarcoGuia())),
    );
    expect(find.text(MarcoGuia.texto), findsOneWidget);
  });
}