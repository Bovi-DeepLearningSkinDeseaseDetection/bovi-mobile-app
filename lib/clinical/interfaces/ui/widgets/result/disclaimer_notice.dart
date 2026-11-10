import 'package:flutter/material.dart';

import '../../../../../shared/interfaces/ui/theme/app_colors.dart';
import 'result_texts.dart';

/// Notice required on every result (HU09, scenario 2).
class DisclaimerNotice extends StatelessWidget {
  const DisclaimerNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mint),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.darkGreen,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              ResultTexts.disclaimerText,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
