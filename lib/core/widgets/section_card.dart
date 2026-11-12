import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border, width: 1.5),
      borderRadius: BorderRadius.circular(32),
    ),
    child: child,
  );
}
