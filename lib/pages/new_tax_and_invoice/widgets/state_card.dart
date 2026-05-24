import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
