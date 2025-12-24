import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Sesuaikan import ini
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
      "title": "Don't Just Study.\nAbsorb It.",
      "desc":
          "Ditch the exam anxiety. We fused Spaced Repetition and Pomodoro so you can hack your memory and learn faster.",
    },
    {
      "title": "Your Second Brain\nis Finally Here.",
      "desc":
          "Capture ideas instantly and organize the chaos. It’s not just notes—it’s a secure vault for your genius.",
    },
    {
      "title": "Crush Your Goals,\nNot Your Sanity.",
      "desc":
          "Smarter insights, better grades, and actual free time. Welcome to the new standard of learning with MIRA.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 1. Background Animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // 2. Floating Icon Animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 15).animate(
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // LAYER 1: Background Animation
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

          // LAYER 2: Blur Filter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),

          // LAYER 3: Main Content (Fixed Constraints)
          SafeArea(
            child: Center(
              // Center memastikan konten di tengah layar besar
              child: ConstrainedBox(
                // PERBAIKAN: Membatasi lebar maksimal agar tidak "gepeng/melebar"
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    // BAGIAN ATAS (ILUSTRASI)
                    Expanded(
                      flex: 5,
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
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: PremiumIllustration(
                                      index: index,
                                      color: index == 1
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // BAGIAN BAWAH (TEKS & TOMBOL)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Page Indicator
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
                                            ? AppColors.textMain
                                            : AppColors.textMuted.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // 2. Title & Desc
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Column(
                                    key: ValueKey<int>(_currentIndex),
                                    children: [
                                      Text(
                                        _contents[_currentIndex]['title']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textMain,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _contents[_currentIndex]['desc']!,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMuted,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // 3. TOMBOL NAVIGASI (Kanan & Kiri Pojok)
                                Row(
                                  // PERBAIKAN: Memastikan tombol di ujung kiri dan kanan
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // KIRI: Tombol Back / Skip
                                    TextButton(
                                      onPressed: _currentIndex == 0
                                          ? _finishOnboarding
                                          : _goToPrevious,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.textMuted,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      // PERBAIKAN: Mengganti Icon Arrow dengan Text "Back"
                                      child: Text(
                                        _currentIndex == 0 ? "Skip" : "Back",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // KANAN: Tombol Next / Let's Go
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
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _currentIndex ==
                                                    _contents.length - 1
                                                ? "Let's Go"
                                                : "Next",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_currentIndex !=
                                              _contents.length - 1) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// --- HELPER CLASSES (Sama seperti sebelumnya) ---

class PremiumIllustration extends StatelessWidget {
  final int index;
  final Color color;

  const PremiumIllustration({
    super.key,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.electric_bolt_rounded;
        break;
      case 1:
        iconData = Icons.auto_awesome_rounded;
        break;
      default:
        iconData = Icons.rocket_launch_rounded;
        break;
    }

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -math.pi / 10,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(),
              ),
            ),
          ),
          Transform.rotate(
            angle: math.pi / 12,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 40, color: color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
