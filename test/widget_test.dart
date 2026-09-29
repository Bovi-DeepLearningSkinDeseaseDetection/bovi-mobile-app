import 'package:flutter_test/flutter_test.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_colors.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:bov_mobile_app/shared/infrastructure/persistence/preferences/preferences_app.dart';
import 'package:flutter/material.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/guide_frame.dart';
import 'package:bov_mobile_app/clinical/interfaces/ui/widgets/help_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('The theme uses the design system primary green', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.primaryGreen);
  });

  // HU03, scenario 1: visible guide.
  testWidgets('The guide displays the framing instructions and distance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GuideFrame())),
    );
    expect(find.text(GuideFrame.instructionText), findsOneWidget);
    expect(find.text(GuideFrame.distanceText), findsOneWidget);
  });

  // HU03, scenario 2: first-time help with examples that can be closed.
  testWidgets('The framing help is displayed in Spanish and can be closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showFramingHelp(context),
              child: const Text('Open help'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open help'));
    await tester.pumpAndSettle();

    expect(find.text('Cómo tomar una buena foto'), findsOneWidget);
    expect(find.text('Cerca, centrada y bien iluminada'), findsOneWidget);
    expect(find.text('Lejos, borrosa o muy oscura'), findsOneWidget);

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(find.text('Cómo tomar una buena foto'), findsNothing);
  });

  test('An existing help preference is migrated to the English key', () async {
    SharedPreferences.setMockInitialValues({'ayuda_encuadre_vista': true});
    final preferences = ApplicationPreferences();

    expect(await preferences.hasSeenHelpFrame(), isTrue);

    final storedPreferences = await SharedPreferences.getInstance();
    expect(storedPreferences.getBool('help_frame_seen'), isTrue);
    expect(storedPreferences.containsKey('ayuda_encuadre_vista'), isFalse);
  });
}
