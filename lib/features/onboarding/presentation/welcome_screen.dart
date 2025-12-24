import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import sesuai struktur project Anda
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Controller untuk background bergerak
  late AnimationController _backgroundController;
  // Controller untuk elemen UI masuk
  late AnimationController _entranceController;

  // Variabel animasi per elemen
  late Animation<double> _fadeTitle;
  late Animation<Offset> _slideTitle;
  late Animation<double> _fadeDesc;
  late Animation<Offset> _slideDesc;
  late Animation<double> _fadeBtn;
  late Animation<Offset> _slideBtn;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi Background (Looping selamanya)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // 2. Setup Animasi Masuk (Sekali jalan)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Definisi Staggered Animation (Muncul bertahap)
    _fadeTitle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    _fadeDesc = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideDesc = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _fadeBtn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _slideBtn = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Mulai animasi masuk
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
    // Mengatur status bar icon menjadi gelap/terang sesuai kebutuhan
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // LAYER 1: The "Living" Background (Tetap Full Screen)
          // Ini memberikan atmosfer ke seluruh layar device
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundOrbPainter(
                  animationValue: _backgroundController.value,
                  // Menggunakan .withValues() pengganti .withOpacity()
                  color1: AppColors.secondary.withValues(alpha: 0.2),
                  color2: AppColors.primary.withValues(alpha: 0.15),
                ),
                size: Size.infinite,
              );
            },
          ),

          // LAYER 2: Glassmorphism Blur (Efek kaca buram)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // LAYER 3: Main Content (DIBATASI LEBARNYA)
          // Menggunakan SafeArea -> Center -> ConstrainedBox agar rapi di tablet/web
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450, // Batas lebar maksimal agar tidak "gepeng"
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),

                      // --- HEADER TITLE SECTION ---
                      FadeTransition(
                        opacity: _fadeTitle,
                        child: SlideTransition(
                          position: _slideTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Garis dekoratif kecil (Visual Anchor)
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Welcome to",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textMain,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              // Gradient Text "MIRA"
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        AppColors.textMain,
                                        AppColors.secondary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: const Text(
                                  "MIRA",
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    color: Colors
                                        .white, // Harus putih agar shader terlihat
                                    height: 0.9,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- DESCRIPTION SECTION ---
                      FadeTransition(
                        opacity: _fadeDesc,
                        child: SlideTransition(
                          position: _slideDesc,
                          child: Container(
                            padding: const EdgeInsets.only(left: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Your integrated ecosystem for mastering retention and academic success.",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textMuted,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // --- BUTTONS SECTION ---
                      FadeTransition(
                        opacity: _fadeBtn,
                        child: SlideTransition(
                          position: _slideBtn,
                          child: Column(
                            children: [
                              // Tombol Utama dengan Glow Effect
                              Container(
                                width: double
                                    .infinity, // Memastikan tombol fill width (sampai 450px)
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: MiraButton(
                                  text: "Get Started",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Tombol Register Outline
                              SizedBox(
                                width: double.infinity,
                                child: MiraButton(
                                  text: "Create Account",
                                  isOutline: true,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 30),

                              Center(
                                child: Text(
                                  "Version 1.0.0",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

// --- CLASS LUKISAN ABSTRAK (Custom Painter) ---
// Bagian ini menggambar bola-bola gradient yang bergerak
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
    // MaskFilter untuk memberikan efek blur yang sangat halus pada bola
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Orb 1 (Kanan Atas)
    final offset1 = Offset(
      size.width * 0.8 + (math.cos(animationValue * 2 * math.pi) * 30),
      size.height * 0.1 + (math.sin(animationValue * 2 * math.pi) * 30),
    );
    paint.color = color1;
    canvas.drawCircle(offset1, size.width * 0.4, paint);

    // Orb 2 (Kiri Tengah)
    final offset2 = Offset(
      size.width * 0.1 + (math.sin(animationValue * 2 * math.pi) * 20),
      size.height * 0.5 + (math.cos(animationValue * 2 * math.pi) * 40),
    );
    paint.color = color2;
    canvas.drawCircle(offset2, size.width * 0.35, paint);

    // Orb 3 (Kanan Bawah)
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
