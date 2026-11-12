import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Starter screen for the Finance feature. Replace with module implementation.
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.blue, size: 54),
              const SizedBox(height: 16),
              const Text('Finance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
              const SizedBox(height: 8),
              const Text('Accounting and expenses', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              const Text('Module implementation coming in a future step.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
