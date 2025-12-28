import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/app_colors.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../widgets/account_settings_screen.dart'; // Pastikan path sesuai
import '../widgets/subscription_screen.dart'; // Pastikan path sesuai
import '../widgets/help_support_screen.dart'; // Pastikan path sesuai
import '../widgets/security_settings_screen.dart'; // <--- TAMBAHKAN IMPORT INI

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final bool isPro = true;
  File? _selectedImage;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 50
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Foto profil berhasil diperbarui!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuka galeri. Pastikan run di Emulator/HP.")),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 140),
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // --- 1. PROFILE PICTURE SECTION ---
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              // FIX: withValues
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ]
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) as ImageProvider
                                : const NetworkImage('https://i.pravatar.cc/300'),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                // FIX: withValues
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3)
                              )
                            ]
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  "Hilmy Baihaqi",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w800, 
                    color: AppColors.textMain,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    // FIX: withValues
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Text(
                    "hilmy@telkomuniversity.ac.id",
                    style: TextStyle(
                      fontSize: 13, 
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. SUBSCRIPTION CARD ---
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SubscriptionScreen())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: isPro 
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF059669), Color(0xFF10B981)]) 
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          // FIX: withValues
                          color: isPro ? const Color(0xFF10B981).withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // FIX: withValues
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isPro ? Icons.verified_user_rounded : Icons.diamond_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPro ? "Pro Member Active" : "Go Premium",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 17
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPro ? "Enjoy all features without limits" : "Unlock AI features & more",
                                style: TextStyle(
                                  // FIX: withValues
                                  color: Colors.white.withValues(alpha: 0.8), 
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(12)
                           ),
                           child: Text(
                             isPro ? "Manage" : "Upgrade", 
                             style: TextStyle(
                               color: isPro ? const Color(0xFF059669) : const Color(0xFF1E293B), 
                               fontSize: 12, 
                               fontWeight: FontWeight.bold
                             ),
                           ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- 3. MENU LIST ---
                _buildSectionHeader("GENERAL"),
                _buildMenuContainer(
                  children: [
                    _buildMenuItem(
                      context,
                      title: "Personal Info",
                      icon: Icons.person_outline_rounded,
                      color: Colors.blue,
                      // Navigasi ke Account Settings
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountSettingsScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      title: "Security & Password",
                      icon: Icons.lock_outline_rounded,
                      color: Colors.purple,
                      // IMPLEMENTASI: Navigasi ke Security Settings
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SecuritySettingsScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      title: "Change Profile Picture",
                      icon: Icons.camera_alt_outlined,
                      color: Colors.pink,
                      onTap: _pickImage,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSectionHeader("PREFERENCES"),
                _buildMenuContainer(
                  children: [
                    _buildMenuItem(
                      context,
                      title: "Help & Support",
                      icon: Icons.headset_mic_outlined,
                      color: Colors.orange,
                      // Navigasi ke Help Support
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpSupportScreen())),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      title: "App Language",
                      icon: Icons.language,
                      color: Colors.teal,
                      onTap: () {},
                      trailingText: "English",
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- 4. LOGOUT BUTTON ---
                _buildMenuContainer(
                  children: [
                    _buildMenuItem(
                      context,
                      title: "Log Out",
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context),
                      showArrow: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // FIX: withValues
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // FIX: withValues
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
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
                Text(
                  trailingText,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 8),
              ],
              if (showArrow)
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1, 
      thickness: 0.5, 
      color: Color(0xFFF1F5F9), 
      indent: 70,
      endIndent: 20,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out from this account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}