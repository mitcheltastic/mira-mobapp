import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // --- CONTROLLERS ---
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _institutionController;

  // --- DROPDOWN STATE ---
  String? _selectedGender;
  String? _selectedOccupation;

  bool _isLoading = false;
  final bool _isPro = true; // Simulasi Status Pro

  // --- DATA LISTS ---
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _occupations = [
    'Elementary Student',
    'Middle School Student',
    'High School Student',
    'College Student',
    'Employee',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Data Awal (Simulasi)
    _nicknameController = TextEditingController(text: "Hilmy");
    _emailController = TextEditingController(text: "hilmy@telkomuniversity.ac.id");
    _ageController = TextEditingController(text: "20");
    _locationController = TextEditingController(text: "Bandung, Indonesia");
    _institutionController = TextEditingController(text: "Telkom University");

    _selectedGender = 'Male';
    _selectedOccupation = 'College Student';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API call
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully!"),
          backgroundColor: AppColors.success, // Gunakan warna sukses konsisten
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
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
            "Personal Info",
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
            children: [
              // --- 1. IDENTITY HEADER ---
              _buildProfileHeader(),

              const SizedBox(height: 30),

              // --- 2. FORM SECTION ---
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
                    // NICKNAME
                    _BuildTextField(
                      label: "Nickname",
                      controller: _nicknameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),

                    // EMAIL (READ ONLY)
                    _BuildTextField(
                      label: "Email Address",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // UMUR & GENDER (Row)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3, // Proporsi lebar lebih baik
                          child: _BuildTextField(
                            label: "Age",
                            controller: _ageController,
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _BuildDropdown(
                            label: "Gender",
                            value: _selectedGender,
                            icon: Icons.wc_outlined,
                            items: _genders,
                            onChanged: (val) =>
                                setState(() => _selectedGender = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LOCATION
                    _BuildTextField(
                      label: "Location",
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),

                    // OCCUPATION (Dropdown)
                    _BuildDropdown(
                      label: "Occupation",
                      value: _selectedOccupation,
                      icon: Icons.work_outline_rounded,
                      items: _occupations,
                      onChanged: (val) =>
                          setState(() => _selectedOccupation = val),
                    ),
                    const SizedBox(height: 20),

                    // INSTITUTION NAME
                    _BuildTextField(
                      label: "Institution Name",
                      controller: _institutionController,
                      icon: Icons.school_outlined,
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF1F5F9),
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nicknameController.text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Badge Status Modern
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isPro
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPro
                  ? const Color(0xFF16A34A).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPro ? Icons.verified_rounded : Icons.person_outline,
                size: 14,
                color: _isPro ? const Color(0xFF15803D) : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                _isPro ? "Pro Active" : "Free Plan",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _isPro ? const Color(0xFF15803D) : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
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
            onPressed: _isLoading ? null : _saveProfile,
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
                    "Save Changes",
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
}

// --- WIDGET HELPER TEXTFIELD (Optimized) ---
class _BuildTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isReadOnly;

  const _BuildTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isReadOnly = false,
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
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          style: TextStyle(
            color: isReadOnly ? Colors.grey[600] : AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly
                ? const Color(0xFFF8FAFC) // Warna background read-only
                : const Color(0xFFFFFFFF), // Putih bersih
            prefixIcon: Icon(
              icon,
              color: isReadOnly ? Colors.grey : const Color(0xFF94A3B8),
              size: 22,
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
            // Hilangkan border read-only agar terlihat clean
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// --- WIDGET HELPER DROPDOWN (Optimized) ---
class _BuildDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final List<String> items;
  final Function(String?) onChanged;

  const _BuildDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8)),
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}