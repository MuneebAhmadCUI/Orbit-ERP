import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 92,
                width: 92,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
                child: const Icon(Icons.dashboard_customize_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text('ORBIT ERP', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('Your business, connected.', style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 38),
              const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
            ],
          ),
        ),
      ),
    );
  }
}
