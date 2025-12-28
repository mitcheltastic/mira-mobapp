import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// Sesuaikan import path
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';
import '../../../core/widgets/mira_text_field.dart';
import 'login_screen.dart';

// Make sure this file actually exists in: lib/features/auth/data/auth_repository.dart
import '../presentation/otp_screen.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;

  // 1. TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 2. LOADING STATE
  bool _isLoading = false;

  late Animation<double> _bgScaleAnimation;
  late AnimationController _formController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Background Animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    // Form Entrance Animation
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    _formController.forward();
  }

  // 3. SINGLE DISPOSE METHOD (Merged)
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // 1. Basic Validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    // 2. Start Loading State
    setState(() => _isLoading = true);

    try {
      // 3. Call the Repository
      final authRepo = AuthRepository();
      await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );

      // 4. Handle Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code sent! Check your email.")),
        );

        // OLD: Navigator.pushReplacement(... LoginScreen ...)

        // NEW: Navigate to OTP Screen
        Navigator.push(
          // Use push so they can go back if email was wrong
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text.trim(), // Pass the email!
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(size),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- HEADER ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 80,
                            child: Lottie.asset(
                              'assets/lottie/BookOpening.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.textMain, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "Join the Ecosystem",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Start building your academic mastery today.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- FORM ---
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 450),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // FIX: Removed 'const' keywords here because controllers are not constant
                              MiraTextField(
                                controller: _nameController,
                                hintText: "Full Name",
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 12),

                              MiraTextField(
                                controller: _emailController,
                                hintText: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),

                              MiraTextField(
                                controller: _passwordController,
                                hintText: "Password",
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                              ),
                              const SizedBox(height: 12),

                              MiraTextField(
                                controller: _confirmPasswordController,
                                hintText: "Confirm Password",
                                icon: Icons.lock_reset_rounded,
                                isPassword: true,
                              ),

                              const SizedBox(height: 24),

                              MiraButton(
                                text: _isLoading
                                    ? "Registering..."
                                    : "Register",
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        _handleRegister();
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- FOOTER ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
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
                                fontSize: 13,
                              ),
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

  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -50,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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
          top: size.height * 0.4,
          left: -80,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
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
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}
