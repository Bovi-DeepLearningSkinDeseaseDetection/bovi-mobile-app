import 'package:bov_mobile_app/shared/interfaces/ui/pages/home_page.dart';
import 'package:bov_mobile_app/shared/interfaces/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the start screen welcomes and offers both main actions', (
    tester,
  ) async {
    var scans = 0;
    var histories = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomePage(onScan: () => scans++, onHistory: () => histories++),
      ),
    );

    expect(find.text(HomePage.welcomeText), findsOneWidget);

    await tester.tap(find.text(HomePage.scanLabel));
    await tester.tap(find.text(HomePage.historyLabel));
    expect(scans, 1);
    expect(histories, 1);
  });
}
