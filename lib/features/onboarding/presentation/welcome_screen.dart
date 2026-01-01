import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constant/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final Color _lightPurpleBtnColor = const Color(0xFF9F7AEA);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE0E7FF),
              const Color(0xFFFAE8FF),
              const Color(0xFFFFE4E6),
              AppColors.surface,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Balls
                _buildColoredBall(
                  top: 40,
                  right: -80,
                  size: 280,
                  color: AppColors.secondary,
                ),

                _buildColoredBall(
                  top: 200,
                  left: -60,
                  size: 200,
                  color: AppColors.primary,
                ),

                _buildColoredBall(
                  top: 90,
                  left: size.width > 450 ? 150 : size.width * 0.35,
                  size: 90,
                  color: AppColors.success,
                ),
                _buildColoredBall(
                  bottom: size.height * 0.55,
                  right: -40,
                  size: 100,
                  color: const Color(0xFFFCD34D),
                ),

                // Glass Card Area
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.60,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(painter: CloudShadowPainter()),
                          ),
                        ),
                        ClipPath(
                          clipper: OrganicCloudClipper(),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.65),
                                border: Border(
                                  top: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content (Text & Buttons)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 50.0),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "MIRA APP",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "Together,\nwe learn better.",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                color: AppColors.textMain,
                                letterSpacing: -1.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              "Join the ultimate ecosystem for retention and academic mastery.",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shadowColor:
                                      _lightPurpleBtnColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.4,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.textMuted.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  foregroundColor: AppColors.textMain,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColoredBall({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    final softColor = color.withValues(alpha: 0.6);
    final coreColor = color.withValues(alpha: 0.9);

    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [softColor, coreColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
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
    double waveH = 40.0;

    path.moveTo(0, h);
    path.lineTo(0, waveH + 20);

    // Bentuk gelombang awan
    path.quadraticBezierTo(w * 0.1, waveH - 20, w * 0.25, waveH + 10);
    path.quadraticBezierTo(w * 0.5, waveH - 50, w * 0.75, waveH);
    path.quadraticBezierTo(w * 0.9, waveH - 20, w, waveH + 10);

    path.lineTo(w, h);
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
      ..color = AppColors.shadow.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(path.shift(const Offset(0, 5)), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}