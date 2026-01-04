import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  // --- CONTROLLERS ---
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // --- STATE VISIBILITY ---
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;
  bool _isSocialLogin = false; 

  @override
  void initState() {
    super.initState();
    _checkLoginProvider();
  }

  // --- 1. LOGIC CHECK PROVIDER (TETAP UTUH) ---
  void _checkLoginProvider() {
    final user = Supabase.instance.client.auth.currentUser;
    // 'provider' biasanya ada di app_metadata.
    final provider = user?.appMetadata['provider'] ?? 'email';

    if (provider != 'email') {
      setState(() {
        _isSocialLogin = true;
      });

      // Show Popup (Sesuai kode asli)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSocialLoginDialog(provider);
      });
    }
  }

  void _showSocialLoginDialog(String provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Action Not Available"),
          content: Text(
            "You are logged in via ${provider[0].toUpperCase()}${provider.substring(1)}. \n\nYou cannot change your password here because your account is managed by your social provider.",
            style: const TextStyle(color: AppColors.textMuted, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Understood",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- 2. LOGIC CHANGE PASSWORD (TETAP UTUH) ---
  Future<void> _changePassword() async {
    // Safety check
    if (_isSocialLogin) return;

    if (_currentPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      _showSnackBar("Please fill in all fields.", isError: true);
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      _showSnackBar("New passwords do not match.", isError: true);
      return;
    }

    if (_newPassController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        _showSnackBar("User not found. Please login again.", isError: true);
        return;
      }

      await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: _currentPassController.text,
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPassController.text),
      );

      if (mounted) {
        _showSnackBar("Password changed successfully!", isError: false);
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showSnackBar(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("An error occurred: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- 3. UI BUILD (MODIFIED FOR CONSISTENCY) ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Background bersih
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Security",
            style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // --- HERO ICON (Visual Konsisten) ---
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isSocialLogin 
                      ? Colors.grey.withValues(alpha: 0.1) 
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSocialLogin ? Icons.no_accounts_rounded : Icons.lock_reset_rounded,
                  color: _isSocialLogin ? Colors.grey : AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Change Password",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Create a strong password to keep your account secure.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
              
              const SizedBox(height: 30),

              // --- FORM CONTAINER ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Jika Social Login, Tampilkan Info Box
                    if (_isSocialLogin)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Password change is disabled for social accounts.",
                                style: TextStyle(
                                  fontSize: 13, 
                                  color: Color(0xFF9A3412), // Dark Orange
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Input Fields (Opacity jika disabled)
                    Opacity(
                      opacity: _isSocialLogin ? 0.5 : 1.0,
                      child: Column(
                        children: [
                          _BuildPasswordField(
                            label: "Current Password",
                            controller: _currentPassController,
                            obscureText: _obscureCurrent,
                            enabled: !_isSocialLogin,
                            onToggleVisibility: () =>
                                setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                          const SizedBox(height: 20),
                          _BuildPasswordField(
                            label: "New Password",
                            controller: _newPassController,
                            obscureText: _obscureNew,
                            enabled: !_isSocialLogin,
                            onToggleVisibility: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          const SizedBox(height: 12),
                          
                          // Requirements
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequirementItem("Min. 6 characters"),
                                _buildRequirementItem("Include 1 special character"),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          _BuildPasswordField(
                            label: "Confirm Password",
                            controller: _confirmPassController,
                            obscureText: _obscureConfirm,
                            enabled: !_isSocialLogin,
                            onToggleVisibility: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isLoading || _isSocialLogin) ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              // Style disabled otomatis dihandle Flutter, tapi bisa dicustom
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _isSocialLogin ? "Managed by Provider" : "Update Password",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, 
            size: 14, 
            color: _isSocialLogin ? Colors.grey : AppColors.success
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET (INPUT FIELD) ---
class _BuildPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final bool enabled;

  const _BuildPasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[100], 
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: enabled ? const Color(0xFF94A3B8) : Colors.grey,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 22,
              ),
              onPressed: enabled ? onToggleVisibility : null,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}