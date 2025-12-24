import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Sesuaikan import dengan struktur project Anda
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';
import '../../../core/widgets/mira_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  // Controller untuk Background Bergerak
  late AnimationController _backgroundController;

  // Controller untuk Animasi Masuk (Entrance)
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup Background Animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // 2. Setup Entrance Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Jalankan animasi masuk
    _entranceController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // LAYER 1: Living Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundOrbPainter(
                  animationValue: _backgroundController.value,
                  color1: AppColors.secondary.withValues(alpha: 0.2),
                  color2: AppColors.primary.withValues(alpha: 0.15),
                ),
                size: Size.infinite,
              );
            },
          ),

          // LAYER 2: Backdrop Blur (Glass Effect)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // LAYER 3: Konten Utama
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                // Membatasi lebar agar tetap rapi di layar lebar
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Tombol Back Custom ---
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textMain),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- Header Section ---
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMain,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start building your second brain today.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textMuted.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- Form Section ---
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              const MiraTextField(
                                hintText: "Full Name",
                                icon: Icons.person_outline_rounded,
                              ),
                              const MiraTextField(
                                hintText: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const MiraTextField(
                                hintText: "Password",
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                              const MiraTextField(
                                hintText: "Confirm Password",
                                icon: Icons.lock_reset_rounded, // Icon berbeda agar intuitif
                                isPassword: true,
                              ),

                              const SizedBox(height: 32),

                              // Sign Up Button
                              MiraButton(
                                text: "Sign Up",
                                onPressed: () {
                                  // Logic Register disini
                                  print("Register Pressed");
                                },
                              ),

                              const SizedBox(height: 32),

                              // Divider "Or"
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "or",
                                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 14),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Footer: Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: AppColors.textMuted),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20), // Extra padding bottom
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Background Painter (Sama dengan Halaman Lain) ---
class BackgroundOrbPainter extends CustomPainter {
  final double animationValue;
  final Color color1;
  final Color color2;

  BackgroundOrbPainter({
    required this.animationValue,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final offset1 = Offset(
      size.width * 0.8 + (math.cos(animationValue * 2 * math.pi) * 30),
      size.height * 0.1 + (math.sin(animationValue * 2 * math.pi) * 30),
    );
    paint.color = color1;
    canvas.drawCircle(offset1, size.width * 0.4, paint);

    final offset2 = Offset(
      size.width * 0.1 + (math.sin(animationValue * 2 * math.pi) * 20),
      size.height * 0.5 + (math.cos(animationValue * 2 * math.pi) * 40),
    );
    paint.color = color2;
    canvas.drawCircle(offset2, size.width * 0.35, paint);

    final offset3 = Offset(
      size.width * 0.8 + (math.cos(animationValue * math.pi) * -20),
      size.height * 0.85 + (math.sin(animationValue * math.pi) * -20),
    );
    paint.color = color1.withValues(alpha: 0.15); 
    canvas.drawCircle(offset3, size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundOrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}