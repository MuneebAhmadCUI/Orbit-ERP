import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Starter screen for the Reports feature. Replace with module implementation.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.blue, size: 54),
              const SizedBox(height: 16),
              const Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
              const SizedBox(height: 8),
              const Text('Insights and exports', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              const Text('Module implementation coming in a future step.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
