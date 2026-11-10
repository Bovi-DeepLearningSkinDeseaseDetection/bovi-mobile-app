import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/value_objects/clinical_code.dart';
import 'result_texts.dart';

/// Standard codes of the detected disease and its causal agent (HU07).
class ClinicalCodesCard extends StatelessWidget {
  final List<ClinicalCode> codes;

  const ClinicalCodesCard({super.key, required this.codes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ResultTexts.codesTitle,
              style: TextTheme.of(context).titleSmall,
            ),
            const SizedBox(height: 10),
            for (final code in codes) _CodeRow(code: code),
          ],
        ),
      ),
    );
  }
}

/// "MeSH D014005" on a soft chip, followed by the official term.
class _CodeRow extends StatelessWidget {
  final ClinicalCode code;

  const _CodeRow({required this.code});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: ShapeDecoration(
              color: AppColors.mint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '${code.systemName} ${code.code}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                code.display,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.bodyText,
                  // Organisms are written in italics.
                  fontStyle: code.isOrganism
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
