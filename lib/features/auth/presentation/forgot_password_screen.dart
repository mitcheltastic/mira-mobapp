import 'dart:ui';
import 'dart:math'
    as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';
import '../../../core/widgets/mira_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

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
          // LAYER 1: Living Background (Menggunakan class Painter di bawah)
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

          // LAYER 2: Backdrop Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // LAYER 3: Main Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spacer agar konten tidak tertutup tombol back
                      const SizedBox(height: 60),

                      // --- Hero Icon (Glass Lock) ---
                      Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 50,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Glass Container
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.4),
                                          Colors.white.withValues(alpha: 0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface.withValues(
                                              alpha: 0.3,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.lock_reset_rounded,
                                            size: 48,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- Text & Form ---
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMain,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Don't worry! It happens. Please enter the email address associated with your account.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 40),

                              const MiraTextField(
                                hintText: "Email Address",
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 32),

                              MiraButton(
                                text: "Send Reset Link",
                                onPressed: () {
                                  // Tampilkan Feedback Dialog
                                  _showSuccessDialog(context);
                                },
                              ),

                              const SizedBox(height: 24),
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

          // LAYER 4: FLOATING BACK BUTTON (SOLID & SHARP)
          Positioned(
            top: 50,
            left: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Solid White agar tidak blur
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.textMain,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(
              alpha: 0.95,
            ), // Hampir solid agar terbaca
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Check your email",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We have sent a password recover instructions to your email.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              MiraButton(
                text: "Back to Login",
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke Login
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- BAGIAN INI YANG SEBELUMNYA HILANG ---
// Pastikan class ini ada di paling bawah file
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
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

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
