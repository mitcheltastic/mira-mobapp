import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constant/app_colors.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constant/app_secrets.dart';

import 'features/onboarding/presentation/splash_screen.dart';
// 1. ADD THIS IMPORT (Make sure the path matches your project structure)
import 'features/dashboard/presentation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(const MiraApp());
}

class MiraApp extends StatelessWidget {
  const MiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIRA - Mastering Information Retention App',
      debugShowCheckedModeBanner: false,

      // --- THEME CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,

        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppColors.textMain,
            displayColor: AppColors.textMain,
          ),
        ),

        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onSurface: AppColors.textMain,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textMain),
          titleTextStyle: TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      home: const SplashScreen(),

      // 2. ADD THIS ROUTES BLOCK
      routes: {'/home': (context) => const MainNavigationScreen()},
    );
  }
}
