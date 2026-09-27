import 'package:flutter/material.dart';
import 'shared/interfaces/ui/theme/app_theme.dart';
import 'clinical/interfaces/ui/pages/capture_page.dart';

void main() {
  runApp(const BoviApp());
}

class BoviApp extends StatelessWidget {
  const BoviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bovi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const CapturePage(),
    );
  }
}
