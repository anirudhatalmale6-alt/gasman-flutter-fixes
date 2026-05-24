import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: child,
    );
  }
}
