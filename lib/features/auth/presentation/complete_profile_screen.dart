import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/app_colors.dart';
import '../../dashboard/presentation/main_navigation_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _bgController;
  late Animation<double> _bgScaleAnimation;

  // --- Form Logic ---
  int _currentStep = 0;
  bool _isLoading = false;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedGender;
  String? _selectedOccupation;
  String? _selectedReferral;

  // --- Data Options ---
  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  final List<String> _occupations = [
    'Elementary Student',
    'Middle School Student',
    'High School Student',
    'College Student',
    'Employee',
    'Educator',
    'Other'
  ];
  final List<String> _referrals = [
    'Friends',
    'Social Media',
    'Ads',
    'Search Engine',
    'Community Event',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _institutionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- Logic Save Data ---
  Future<void> _submitData() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('profiles').update({
        'nickname': _nicknameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _selectedGender,
        'occupation': _selectedOccupation,
        'institution_name': _institutionController.text.trim(),
        'location': _locationController.text.trim(),
        'referral_source': _selectedReferral,
        'updated_at': DateTime.now().toIso8601String(),
        'status': 'online',
      }).eq('id', user.id);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar("Error saving profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_nicknameController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _selectedGender == null) {
        _showSnackBar("Please fill in all identity fields.");
        return false;
      }
    } else if (_currentStep == 1) {
      if (_selectedOccupation == null ||
          _institutionController.text.isEmpty ||
          _locationController.text.isEmpty) {
        _showSnackBar("Please complete your work details.");
        return false;
      }
    } else if (_currentStep == 2) {
      if (_selectedReferral == null) {
        _showSnackBar("Please select a source.");
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        } else {
          _submitData();
        }
      });
    }
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // 1. Background Animation (Konsisten dengan Splash)
            RepaintBoundary(
              child: _buildAnimatedBackground(size),
            ),

            // 2. Content (Floating Elements)
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeOutQuart,
                      switchOutCurve: Curves.easeInQuart,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(_currentStep),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCurrentStepContent(),
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER SECTION ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SETUP PROFILE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textMain.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Step ${_currentStep + 1} of 3",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              // Step Indicator Circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: (_currentStep + 1) / 3,
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FORM CONTENT ---

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepOne();
      case 1:
        return _buildStepTwo();
      case 2:
        return _buildStepThree();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeadline("Identity", "Tell us who you are."),
        const SizedBox(height: 30),
        _buildInputWithBackground(
          controller: _nicknameController,
          label: "Nickname",
          hint: "e.g. Mira Explorer",
          icon: Icons.person_rounded,
        ),
        const SizedBox(height: 20),
        _buildInputWithBackground(
          controller: _ageController,
          label: "Age",
          hint: "e.g. 21",
          icon: Icons.cake_rounded,
          isNumber: true,
        ),
        const SizedBox(height: 24),
        _buildLabel("Gender Identity"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _genders.map((g) => _buildSolidChip(
            label: g,
            isSelected: _selectedGender == g,
            onTap: () => setState(() => _selectedGender = g),
          )).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeadline("Profession", "What do you do?"),
        const SizedBox(height: 30),
        _buildLabel("Occupation"),
        const SizedBox(height: 8),
        _buildDropdownWithBackground(),
        const SizedBox(height: 20),
        _buildInputWithBackground(
          controller: _institutionController,
          label: "Institution / Company",
          hint: "e.g. Telkom University",
          icon: Icons.business_rounded,
        ),
        const SizedBox(height: 20),
        _buildInputWithBackground(
          controller: _locationController,
          label: "Location",
          hint: "e.g. Bandung",
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildHeadline("Source", "How did you find us?"),
        const SizedBox(height: 30),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _referrals.length,
          itemBuilder: (context, index) {
            final item = _referrals[index];
            return _buildSolidChip(
              label: item,
              isSelected: _selectedReferral == item,
              onTap: () => setState(() => _selectedReferral = item),
              isCentered: true,
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // --- REUSABLE WIDGETS (WITH BACKGROUND EFFECT) ---

  Widget _buildHeadline(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
    );
  }

  // ✨ INI DIA BACKGROUND EFFECT UNTUK INPUT ✨
  Widget _buildInputWithBackground({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background Putih Solid
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Efek Shadow Halus agar 'pop-up'
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, // Background Putih Solid
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOccupation,
          isExpanded: true,
          hint: Text("Select Option", style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMain),
          borderRadius: BorderRadius.circular(16),
          items: _occupations.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedOccupation = val),
        ),
      ),
    );
  }

  Widget _buildSolidChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCentered = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        alignment: isCentered ? Alignment.center : null,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white, // Solid Background
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.3) 
                  : AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
             color: isSelected ? Colors.transparent : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMain,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isLoading ? null : _prevStep,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text("Back"),
              ),
            ),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Warna Solid
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == 2 ? "Finish Setup" : "Continue",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BACKGROUND ANIMATION (SAMA DENGAN SPLASH) ---
  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -50,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
          top: size.height * 0.3,
          left: -80,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
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
        Positioned(
          bottom: -50,
          right: -20,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFCD34D),
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