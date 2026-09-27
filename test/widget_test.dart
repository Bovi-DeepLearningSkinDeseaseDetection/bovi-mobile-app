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

  testWidgets('The guide displays the framing instructions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GuideFrame())),
    );
    expect(find.text(GuideFrame.instructionText), findsOneWidget);
  });

  testWidgets('The framing help is displayed in English', (tester) async {
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

    expect(find.text('How to take a good photo'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
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
