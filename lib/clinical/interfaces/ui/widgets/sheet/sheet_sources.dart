import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import '../../../../domain/model/value_objects/disease_sheet.dart';

/// Public references of the sheet; the addresses can be selected and
/// copied to open them later.
class SheetSources extends StatelessWidget {
  final List<SheetSource> sources;

  const SheetSources({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fuentes', style: textTheme.titleSmall),
        for (final source in sources)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${source.title}\n',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                  ),
                  TextSpan(
                    text: source.url,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
