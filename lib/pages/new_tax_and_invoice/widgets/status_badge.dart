import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.success;

    if (status == "Unpaid") color = AppColors.warning;
    if (status == "Overdue") color = AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color),
      ),
    );
  }
}
