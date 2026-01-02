import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isFetching = true;
  final bool _isPro = true;

  // --- AVATAR STATE ---
  String? _avatarUrl;

  // --- DATA LISTS ---
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _occupations = [
    'Elementary Student',
    'Middle School Student',
    'High School Student',
    'College Student',
    'Employee',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _locationController = TextEditingController();
    _institutionController = TextEditingController();

    _getProfileData();
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

  // --- 1. FETCH DATA ---
  Future<void> _getProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      _emailController.text = user.email ?? "";

      // We use .maybeSingle() instead of .single() to prevent crashes if row is missing
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (data != null) {
            _nicknameController.text = data['nickname'] ?? '';
            _ageController.text = data['age']?.toString() ?? '';
            _locationController.text = data['location'] ?? '';
            _institutionController.text = data['institution_name'] ?? '';
            _avatarUrl = data['avatar_url'];

            if (_genders.contains(data['gender'])) {
              _selectedGender = data['gender'];
            }
            if (_occupations.contains(data['occupation'])) {
              _selectedOccupation = data['occupation'];
            }
          }
          _isFetching = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // --- 2. UPDATE/UPSERT DATA (THE FIX) ---
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 1. Include the 'id' in the updates map
      final updates = {
        'id':
            user.id, // CRITICAL: Required for Upsert to know which row to touch
        'nickname': _nicknameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'gender': _selectedGender,
        'location': _locationController.text.trim(),
        'occupation': _selectedOccupation,
        'institution_name': _institutionController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint("Attempting to Upsert: $updates");

      // 2. Use UPSERT instead of UPDATE
      // This creates the row if it's missing, or updates it if it exists.
      final response = await Supabase.instance.client
          .from('profiles')
          .upsert(updates)
          .select(); // .select() ensures we get a response back to verify success

      debugPrint("Upsert Success: $response");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully!"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Upsert Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating profile: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Personal Info",
            style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
        body: _isFetching
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
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
                          _BuildTextField(
                            label: "Nickname",
                            controller: _nicknameController,
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 20),
                          _BuildTextField(
                            label: "Email Address",
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            isReadOnly: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
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
                          _BuildTextField(
                            label: "Location",
                            controller: _locationController,
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 20),
                          _BuildDropdown(
                            label: "Occupation",
                            value: _selectedOccupation,
                            icon: Icons.work_outline_rounded,
                            items: _occupations,
                            onChanged: (val) =>
                                setState(() => _selectedOccupation = val),
                          ),
                          const SizedBox(height: 20),
                          _BuildTextField(
                            label: "Institution Name",
                            controller: _institutionController,
                            icon: Icons.school_outlined,
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

  Widget _buildProfileHeader() {
    ImageProvider imageProvider;
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    } else {
      imageProvider = const NetworkImage(
        'https://ui-avatars.com/api/?name=User&background=random',
      );
    }

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
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: imageProvider,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nicknameController.text.isEmpty
              ? "New User"
              : _nicknameController.text,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isPro ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
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

// --- HELPER WIDGETS ---

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
            fillColor: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
            prefixIcon: Icon(
              icon,
              color: isReadOnly ? Colors.grey : const Color(0xFF94A3B8),
              size: 22,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
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
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
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
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
