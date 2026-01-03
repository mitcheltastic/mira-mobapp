import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constant/app_colors.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constant/app_secrets.dart';

import 'features/onboarding/presentation/splash_screen.dart';
// 1. ADD THIS IMPORT (Make sure the path matches your project structure)
import 'features/dashboard/presentation/main_navigation_screen.dart';
import 'core/services/presence_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ADD THIS LINE to actually load the .env file
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(const MiraApp());
}

class MiraApp extends StatefulWidget {
  const MiraApp({super.key});

  @override
  State<MiraApp> createState() => _MiraAppState();
}

class _MiraAppState extends State<MiraApp> {
  @override
  void initState() {
    super.initState();
    _initPresence();
  }

  // 🔥 Step 2: Ignite Presence Service
  void _initPresence() async {
    // Wait for Supabase Auth to settle
    await Future.delayed(const Duration(seconds: 1));

    // 1. Connect if already logged in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await PresenceService().connect();
    }

    // 2. Listen for future Login/Logout events
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        PresenceService().connect();
      } else if (data.event == AuthChangeEvent.signedOut) {
        PresenceService().disconnect();
      }
    });
  }

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

      routes: {'/home': (context) => const MainNavigationScreen()},
    );
  }
}
