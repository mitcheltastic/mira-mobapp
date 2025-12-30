import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/auth_repository.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';
import '../../../core/widgets/mira_text_field.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../dashboard/presentation/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgScaleAnimation;
  late AnimationController _formController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final LocalAuthentication auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Email address is required.");
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Password is required.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      await authRepo.signIn(email: email, password: password);
      final String? isThisUserEnabled =
          await _storage.read(key: 'bio_enabled_$email');
      final String? isThisUserIgnored =
          await _storage.read(key: 'bio_ignored_$email');

      if (mounted) {
        _showSnackBar("Welcome back!", isError: false);
        if (isThisUserEnabled == 'true') {
          await _storage.write(key: 'bio_pass_$email', value: password);
          await _storage.write(key: 'last_bio_user', value: email);

          _navigateToDashboard();
        } else {
          if (isThisUserIgnored == 'true') {
            _navigateToDashboard();
          } else {
            await _askToEnableBiometrics(email, password);
          }
        }
      }
    } on AuthException catch (e) {
      String errorMessage = e.message;
      if (e.message.toLowerCase().contains("invalid login credentials")) {
        errorMessage = "Incorrect email or password.";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _askToEnableBiometrics(String email, String password) async {
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      _navigateToDashboard();
      return;
    }

    if (!mounted) return;
    bool doNotAskAgain = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Enable Biometric Login?"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Would you like to use fingerprint/face ID for $email?",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setStateDialog(() {
                        doNotAskAgain = !doNotAskAgain;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: doNotAskAgain,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setStateDialog(
                                  () => doNotAskAgain = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Don't ask me again for this account",
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    if (doNotAskAgain) {
                      await _storage.write(
                          key: 'bio_ignored_$email', value: 'true');
                    }

                    _navigateToDashboard();
                  },
                  child:
                      const Text("Skip", style: TextStyle(color: Colors.grey)),
                ),

                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    try {
                      bool didAuthenticate = await auth.authenticate(
                        localizedReason:
                            'Authenticate to enable biometric login',
                        options: const AuthenticationOptions(stickyAuth: true),
                      );

                      if (didAuthenticate) {
                        await _storage.write(
                            key: 'bio_enabled_$email', value: 'true');
                        await _storage.write(
                            key: 'bio_pass_$email', value: password);
                        await _storage.delete(key: 'bio_ignored_$email');
                        await _storage.write(
                            key: 'last_bio_user', value: email);

                        if (mounted) {
                          _showSnackBar("Biometric login enabled!",
                              isError: false);
                        }
                      }
                    } catch (e) {
                      debugPrint("Bio setup error: $e");
                    }

                    _navigateToDashboard();
                  },
                  child: const Text("Yes, Enable",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    String? lastUserEmail = await _storage.read(key: 'last_bio_user');

    if (lastUserEmail == null) {
      _showSnackBar(
          'No biometric account linked yet. Please login manually first.');
      return;
    }

    String? isEnabled =
        await _storage.read(key: 'bio_enabled_$lastUserEmail');

    if (isEnabled != 'true') {
      _showSnackBar(
          'Biometrics disabled for $lastUserEmail. Please login manually.');
      return;
    }

    final bool canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      _showSnackBar('Biometrics not available on this device');
      return;
    }

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Login as $lastUserEmail',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() => _isLoading = true);
        final savedPassword =
            await _storage.read(key: 'bio_pass_$lastUserEmail');

        if (savedPassword != null) {
          final authRepo = AuthRepository();
          await authRepo.signIn(
              email: lastUserEmail, password: savedPassword);

          if (mounted) {
            _showSnackBar("Login Successful via Biometrics!", isError: false);
            _navigateToDashboard();
          }
        } else {
          _showSnackBar("Credentials missing. Please login manually.");
        }
      }
    } on AuthException catch (e) {
      _showSnackBar("Login failed: ${e.message}");
    } catch (e) {
      _showSnackBar("Biometric Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      const webClientId =
          '95756928282-jnmgsvcusb26oql90mugkepbqe0qije3.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn =
          GoogleSignIn(serverClientId: webClientId);

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID Token found.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        _showSnackBar("Google Login Successful!", isError: false);
        _navigateToDashboard();
      }
    } catch (error) {
      _showSnackBar("Google Login Failed: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          RepaintBoundary(
            child: _buildAnimatedBackground(size),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: RepaintBoundary(
                              child: Lottie.asset(
                                'assets/lottie/BookOpening.json',
                                fit: BoxFit.contain,
                                frameRate: FrameRate.max,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.textMain, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "Welcome Back!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Ready to continue your mastery?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 450),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 20),

                              MiraTextField(
                                controller: _emailController,
                                hintText: "Email Address",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 16),

                              MiraTextField(
                                controller: _passwordController,
                                hintText: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: MiraButton(
                                      text: _isLoading
                                          ? "Logging In..."
                                          : "Log In",
                                      onPressed:
                                          _isLoading ? null : _handleLogin,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.fingerprint,
                                        size: 28,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: _isLoading 
                                          ? null 
                                          : _authenticateWithBiometrics,
                                      tooltip: "Login with Fingerprint",
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const _DividerWithText(text: "or"),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed:
                                      _isLoading ? null : _googleSignIn,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.g_mobiledata_rounded,
                                        size: 30,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "New to Mira? ",
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Create an Account",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
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
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
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
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
              color: AppColors.textMuted.withValues(alpha: 0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
              color: AppColors.textMuted.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}