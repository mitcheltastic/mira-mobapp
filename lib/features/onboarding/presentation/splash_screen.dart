import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _bgController;
  late Animation<double> _bgScaleAnimation;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _navigateToNextScreen();
          }
        });
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    Widget nextScreen;
    if (session != null) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const OnboardingScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          RepaintBoundary(
            child: _buildAnimatedBackground(size),
          ),

          Center(
            child: SizedBox(
              width: size.width * 0.8,
              child: RepaintBoundary(
                child: Lottie.asset(
                  'assets/lottie/magic.json',
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  frameRate: FrameRate.max,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..forward();
                  },
                  frameBuilder: (context, child, composition) {
                    if (composition != null) {
                      return child;
                    } else {
                      return const SizedBox();
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.book_rounded,
                      size: 100,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        // Orb 1 (Atas Kanan)
        Positioned(
          top: -80,
          right: -50,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: size.height * 0.3,
          left: -80,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -50,
          right: -20,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFCD34D),
                ),
              ),
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}