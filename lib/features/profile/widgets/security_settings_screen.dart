import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // --- LOGIC GANTI PASSWORD ---
  Future<void> _changePassword() async {
    // 1. Validasi Input Kosong
    if (_currentPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      _showSnackBar("Please fill in all fields.", isError: true);
      return;
    }

    // 2. Validasi Match
    if (_newPassController.text != _confirmPassController.text) {
      _showSnackBar("New passwords do not match.", isError: true);
      return;
    }

    // 3. Validasi Panjang (Contoh)
    if (_newPassController.text.length < 8) {
      _showSnackBar("Password must be at least 8 characters.", isError: true);
      return;
    }

    // 4. Proses Simpan
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnackBar("Password changed successfully!", isError: false);

      // Opsional: Clear field setelah sukses
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();

      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Background bersih
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMain, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Security",
            style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w800,
                fontSize: 18),
          ),
        ),
        // Bottom Bar untuk Tombol Save (Agar selalu terlihat)
        bottomNavigationBar: _buildBottomBar(),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your new password must be different from previously used passwords.",
                style: TextStyle(
                    fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),

              // --- FORM SECTION ---
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
                    // CURRENT PASSWORD
                    _BuildPasswordField(
                      label: "Current Password",
                      controller: _currentPassController,
                      obscureText: _obscureCurrent,
                      onToggleVisibility: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),

                    const SizedBox(height: 10),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    // NEW PASSWORD
                    _BuildPasswordField(
                      label: "New Password",
                      controller: _newPassController,
                      obscureText: _obscureNew,
                      onToggleVisibility: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 12),

                    // PASSWORD REQUIREMENTS
                    _buildRequirementItem("Must be at least 8 characters"),
                    _buildRequirementItem(
                        "Must contain one special character"),

                    const SizedBox(height: 20),

                    // CONFIRM PASSWORD
                    _BuildPasswordField(
                      label: "Confirm Password",
                      controller: _confirmPassController,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],
                ),
              ),
              // Tambahan padding bawah agar tidak tertutup keyboard/bottom bar
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

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
            onPressed: _isLoading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0, // Flat design
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
                : const Text(
                    "Change Password",
                    style: TextStyle(
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
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Indikator hijau kecil
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET HELPER PASSWORD FIELD (Optimized) ---
class _BuildPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  const _BuildPasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
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
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF94A3B8), size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            // Border Logic
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFFE2E8F0), // Border abu muda
                width: 1,
              ),
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