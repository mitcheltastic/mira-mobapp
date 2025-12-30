import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// --- Ganti import ini sesuai struktur foldermu ---
import '../../../core/constant/app_colors.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<Map<String, String>> _contents = [
    {
      "lottie": "assets/lottie/1.json",
      "title": "Don't Just Study.\nAbsorb It.",
      "desc":
          "Ditch the exam anxiety. We fused Spaced Repetition and Pomodoro so you can hack your memory and learn faster.",
    },
    {
      "lottie": "assets/lottie/2.json",
      "title": "Your Second Brain\nis Finally Here.",
      "desc":
          "Capture ideas instantly and organize the chaos. It’s not just notes, it’s a secure vault for your genius.",
    },
    {
      "lottie": "assets/lottie/3.json",
      "title": "Crush Your Goals,\nNot Your Sanity.",
      "desc":
          "Smarter insights, better grades, and actual free time. Welcome to the new standard of learning with MIRA.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Background Animation (OPTIMIZED: Wrapped in RepaintBoundary)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundOrbPainter(
                      animationValue: _backgroundController.value,
                      color1: AppColors.secondary.withValues(alpha: 0.1),
                      color2: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // 2. Full Screen Blur (OPTIMIZED: Reduced sigma for performance)
          // Mengurangi sigma dari 30 ke 15 mengurangi beban GPU signifikan
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: const SizedBox.expand(),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentIndex = index),
                        itemCount: _contents.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _floatAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    // OPTIMIZED: RepaintBoundary & FrameRate
                                    child: RepaintBoundary(
                                      child: Lottie.asset(
                                        _contents[index]['lottie']!,
                                        width: screenHeight * 0.35,
                                        fit: BoxFit.contain,
                                        frameRate: FrameRate.max, 
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image_not_supported,
                                            size: 100,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Bottom Cloud Container
                    SizedBox(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            top: 40,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            // OPTIMIZED: RepaintBoundary for static shadow
                            child: RepaintBoundary(
                              child: CustomPaint(painter: CloudShadowPainter()),
                            ),
                          ),
                          ClipPath(
                            clipper: OrganicCloudClipper(),
                            child: BackdropFilter(
                              // OPTIMIZED: Reduced blur sigma
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.surface.withValues(
                                  alpha: 0.75,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  75,
                                  24,
                                  40,
                                ),
                                child: const SizedBox(height: 250),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 75, 24, 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Page Indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _contents.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      height: 6,
                                      width: _currentIndex == index ? 24 : 8,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? AppColors.primary
                                            : AppColors.textMain.withValues(
                                                alpha: 0.2,
                                              ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  child: Column(
                                    key: ValueKey<int>(_currentIndex),
                                    children: [
                                      Text(
                                        _contents[_currentIndex]['title']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textMain,
                                          height: 1.2,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _contents[_currentIndex]['desc']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMuted,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton(
                                      onPressed: _currentIndex == 0
                                          ? _finishOnboarding
                                          : _goToPrevious,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: const Color.fromARGB(
                                                  0, 255, 255, 255)
                                              .withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _currentIndex == 0 ? "Skip" : "Back",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _goToNext,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: AppColors.primary
                                            .withValues(alpha: 0.4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _currentIndex ==
                                                    _contents.length - 1
                                                ? "Let's go"
                                                : "Next",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_currentIndex !=
                                              _contents.length - 1) ...[
                                            const SizedBox(width: 8),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrganicCloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;
    double waveH = 55.0;
    path.moveTo(0, h);
    path.lineTo(0, waveH);
    path.quadraticBezierTo(w * 0.1, waveH - 25, w * 0.25, waveH - 10);
    path.quadraticBezierTo(w * 0.4, waveH - 50, w * 0.55, waveH - 15);
    path.quadraticBezierTo(w * 0.65, waveH - 35, w * 0.8, waveH - 10);
    path.quadraticBezierTo(w * 0.9, waveH - 25, w, waveH);

    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CloudShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = OrganicCloudClipper().getClip(size);

    var shadowPaint = Paint()
      ..color = AppColors.shadow.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(path.shift(const Offset(0, 5)), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    // OPTIMIZED: Reduced Blur Mask Filter
    // Blur 60 sangat berat, 40 masih memberikan efek serupa tapi lebih ringan
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final offset1 = Offset(
      size.width * 0.8 + (math.cos(animationValue * 2 * math.pi) * 30),
      size.height * 0.2 + (math.sin(animationValue * 2 * math.pi) * 30),
    );
    paint.color = color1;
    canvas.drawCircle(offset1, size.width * 0.4, paint);

    final offset2 = Offset(
      size.width * 0.2 + (math.sin(animationValue * 2 * math.pi) * 20),
      size.height * 0.4 + (math.cos(animationValue * 2 * math.pi) * 40),
    );
    paint.color = color2;
    canvas.drawCircle(offset2, size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundOrbPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}