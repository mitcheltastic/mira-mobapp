import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/app_colors.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../../auth/data/auth_repository.dart';

// Import Sub-screens
import '../widgets/account_settings_screen.dart';
import '../widgets/subscription_screen.dart';
import '../widgets/help_support_screen.dart';
import '../widgets/security_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- STATE VARIABLES ---
  final bool isPro = true;
  File? _selectedImage;

  // Data User
  String _fullName = "Loading...";
  String _email = "Loading...";

  @override
  void initState() {
    super.initState();
    // Animasi manual DIHAPUS agar transisi "Normal" dan Ringan
    _getProfileData();
  }

  // --- FUNGSI DATA ---
  Future<void> _getProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        setState(() => _email = user.email ?? "No Email");

        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() => _fullName = data['full_name'] ?? "User");
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => _fullName = "User");
    }
  }

  // --- FUNGSI GAMBAR ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Profile updated!"),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Background bersih
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 140),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- 1. HEADER PROFILE ---
            _buildProfileHeader(),

            const SizedBox(height: 30),

            // --- 2. SUBSCRIPTION CARD ---
            _buildSubscriptionCard(),

            const SizedBox(height: 30),

            // --- 3. MENU LIST ---
            _buildSectionHeader("GENERAL"),
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  title: "Personal Info",
                  icon: Icons.person_outline_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountSettingsScreen())),
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: "Security & Password",
                  icon: Icons.lock_outline_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SecuritySettingsScreen())),
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: "Change Photo",
                  icon: Icons.camera_alt_outlined,
                  color: Colors.pink,
                  onTap: _pickImage,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionHeader("PREFERENCES"),
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  title: "Help & Support",
                  icon: Icons.headset_mic_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpSupportScreen())),
                ),
                _buildDivider(),
                _buildMenuItem(
                  title: "App Language",
                  icon: Icons.language,
                  color: Colors.teal,
                  trailingText: "English",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 4. LOGOUT ---
            _buildMenuCard(
              children: [
                _buildMenuItem(
                  title: "Log Out",
                  icon: Icons.logout_rounded,
                  color: AppColors.error,
                  isDestructive: true,
                  showArrow: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Dipecah agar kode bersih) ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[100],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : const NetworkImage('https://ui-avatars.com/api/?name=User&background=random'),
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _email,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SubscriptionScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPro
              ? const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1E293B)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isPro ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(isPro ? Icons.verified_user_rounded : Icons.diamond_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? "Pro Active" : "Upgrade to Pro",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPro ? "Unlimited Access" : "Unlock all features",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted.withValues(alpha: 0.7),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showArrow = true,
    String? trailingText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.textMain,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(trailingText, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
              ],
              if (showArrow)
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFF1F5F9), indent: 64, endIndent: 20);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthRepository().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}