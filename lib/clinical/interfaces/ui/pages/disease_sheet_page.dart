import 'package:flutter/material.dart';

import '../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../domain/model/value_objects/disease_sheet.dart';
import '../../../infrastructure/catalog/lesion_class_catalog.dart';
import '../widgets/result/disclaimer_notice.dart';
import '../widgets/sheet/contagion_card.dart';
import '../widgets/sheet/sheet_section.dart';
import '../widgets/sheet/sheet_sources.dart';

/// Information sheet of the detected disease (HU09, scenario 1): visible
/// signs, whether it spreads and preventive measures that are not clinical.
class DiseaseSheetPage extends StatelessWidget {
  static const signsTitle = 'Signos visibles';
  static const preventionTitle = 'Medidas preventivas';
  static const vetTitle = 'Cuándo llamar al veterinario';

  final DiseaseSheet sheet;

  const DiseaseSheetPage({super.key, required this.sheet});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha informativa')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              LesionClassCatalog.displayName(sheet.label),
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              sheet.summary,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.bodyText),
            ),
            const SizedBox(height: 20),
            SheetSection(
              icon: Icons.visibility_outlined,
              title: signsTitle,
              points: sheet.signs,
            ),
            const SizedBox(height: 16),
            ContagionCard(sheet: sheet),
            const SizedBox(height: 16),
            SheetSection(
              icon: Icons.shield_outlined,
              title: preventionTitle,
              points: sheet.prevention,
            ),
            const SizedBox(height: 16),
            SheetSection(
              icon: Icons.medical_services_outlined,
              title: vetTitle,
              text: sheet.whenToCallVet,
            ),
            const SizedBox(height: 16),
            // HU09, scenario 2: the notice goes with every result.
            const DisclaimerNotice(),
            const SizedBox(height: 20),
            SheetSources(sources: sheet.sources),
          ],
        ),
      ),
    );
  }
}
