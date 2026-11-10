import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/value_objects/body_zone.dart';

/// Asks where the lesion is (HU15, scenario 3). One tap chooses the zone.
Future<BodyZone?> showBodyZonePicker(
  BuildContext context, {
  BodyZone? selected,
}) {
  return showModalBottomSheet<BodyZone>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.white,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Zona de la lesión',
              style: TextTheme.of(context).headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final zone in BodyZone.values)
                  ChoiceChip(
                    label: Text(zone.label),
                    selected: zone == selected,
                    onSelected: (_) => Navigator.of(context).pop(zone),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
