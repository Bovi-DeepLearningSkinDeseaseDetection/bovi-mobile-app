import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/value_objects/disease_sheet.dart';

/// Whether the disease spreads between animals and to people (HU09,
/// scenario 1), with an amber tone when it does.
class ContagionCard extends StatelessWidget {
  final DiseaseSheet sheet;

  const ContagionCard({super.key, required this.sheet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Notice(
          warning: sheet.contagious,
          icon: sheet.contagious
              ? Icons.groups_outlined
              : Icons.do_not_disturb_on_outlined,
          title: sheet.contagious
              ? 'Contagiosa entre animales'
              : 'No se contagia por contacto',
          text: sheet.contagion,
        ),
        const SizedBox(height: 12),
        _Notice(
          warning: sheet.affectsPeople,
          icon: Icons.person_outline_rounded,
          title: sheet.affectsPeople
              ? 'Puede afectar a personas'
              : 'No afecta a personas',
          text: sheet.peopleNote,
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final bool warning;
  final IconData icon;
  final String title;
  final String text;

  const _Notice({
    required this.warning,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.reviewText : AppColors.healthyText;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warning ? AppColors.reviewSurface : AppColors.healthySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
