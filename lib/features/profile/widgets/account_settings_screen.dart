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
          backgroundColor: Colors.green,
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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Personal Info",
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- 1. IDENTITY HEADER ---
              Column(
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
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Menampilkan Nickname di Header
                  Text(
                    _nicknameController.text,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isPro ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _isPro ? const Color(0xFF16A34A) : Colors.grey),
                    ),
                    child: Text(
                      _isPro ? "Pro Active" : "Free Plan",
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: _isPro ? const Color(0xFF15803D) : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- 2. FORM SECTION ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // NICKNAME
                    _buildTextField("Nickname", _nicknameController, Icons.person_outline),
                    const SizedBox(height: 20),
                    
                    // EMAIL (READ ONLY)
                    _buildTextField(
                      "Email Address", 
                      _emailController, 
                      Icons.email_outlined, 
                      isReadOnly: true // KUNCI DISINI
                    ),
                    const SizedBox(height: 20),
                    
                    // UMUR & GENDER (Row)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            "Age", 
                            _ageController, 
                            Icons.calendar_today_outlined, 
                            keyboardType: TextInputType.number
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildDropdown(
                            "Gender", 
                            _selectedGender, 
                            Icons.wc_outlined, 
                            _genders,
                            (val) => setState(() => _selectedGender = val)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LOCATION
                    _buildTextField("Location", _locationController, Icons.location_on_outlined),
                    const SizedBox(height: 20),

                    // OCCUPATION (Dropdown)
                    _buildDropdown(
                      "Occupation", 
                      _selectedOccupation, 
                      Icons.work_outline_rounded, 
                      _occupations,
                      (val) => setState(() => _selectedOccupation = val)
                    ),
                    const SizedBox(height: 20),

                    // INSTITUTION NAME
                    _buildTextField("Institution Name", _institutionController, Icons.school_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // --- BUTTON SAVE ---
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER TEXTFIELD ---
  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    {
      TextInputType keyboardType = TextInputType.text,
      bool isReadOnly = false,
    }
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          style: TextStyle(
            color: isReadOnly ? Colors.grey[600] : AppColors.textMain, 
            fontWeight: FontWeight.w500
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF1F5F9) : Colors.white,
            prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : const Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            // Border Logic
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0)), // Standard border grey
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER DROPDOWN ---
  Widget _buildDropdown(
    String label,
    String? value,
    IconData icon,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}