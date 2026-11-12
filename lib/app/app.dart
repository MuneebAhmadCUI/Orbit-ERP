import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/screens/splash_screen.dart';

class ErpApp extends StatelessWidget {
  const ErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbit ERP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondaryContainer: AppColors.pale,
          surface: Colors.white,
          onSurface: AppColors.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.dark,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
          margin: EdgeInsets.zero,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(28),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.pale,
          circularTrackColor: AppColors.pale,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorShape: const StadiumBorder(),
          backgroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
