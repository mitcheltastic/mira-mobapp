import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart'; // IMPORT SHIMMER

import '../widgets/biometric_settings_screen.dart';
import '../../../core/constant/app_colors.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../../auth/data/auth_repository.dart';
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
  File? _selectedImage;
  String? _avatarUrl;
  bool _isUploading = false;
  bool _isLoadingProfile = true;

  // Data User
  String _fullName = "User";
  String _email = "";
  String _subscriptionStatus = "Regular"; 

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  // --- FUNGSI DATA ---
  Future<void> _getProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Delay sedikit agar skeleton terlihat (opsional, untuk UX feel)
        // await Future.delayed(const Duration(milliseconds: 800)); 
        
        if (mounted) setState(() => _isLoadingProfile = true);

        _email = user.email ?? "";

        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', user.id)
            .maybeSingle();

        final levelData = await Supabase.instance.client
            .from('level')
            .select('status')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            if (profileData != null) {
              _fullName = profileData['full_name'] ?? "User";
              _avatarUrl = profileData['avatar_url'];
              
              if (_avatarUrl != null) {
                 _avatarUrl = "$_avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}";
              }
            }

            if (levelData != null && levelData['status'] != null) {
              _subscriptionStatus = levelData['status'];
            }
            
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // --- FUNGSI UPLOAD ---
  Future<void> _uploadAvatar(File imageFile) async {
    setState(() => _isUploading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${user.id}/avatar.$fileExtension'; 

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      final cleanUrl = Uri.parse(imageUrl).removeFragment().toString();

      await Supabase.instance.client
          .from('profiles')
          .update({
            'avatar_url': cleanUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = "$cleanUrl?t=${DateTime.now().millisecondsSinceEpoch}";
          _selectedImage = null;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated!"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fail: $e")));
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      await _uploadAvatar(File(image.path));
    }
  }

  Future<void> _navigateToSubscription() async {
    await Navigator.push(context, MaterialPageRoute(builder: (c) => const SubscriptionScreen()));
    _getProfileData();
  }

  void _showLogoutDialog(BuildContext context) {
    // ... (Kode Logout sama seperti sebelumnya)
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await AuthRepository().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const WelcomeScreen()),
                  (r) => false,
                );
              }
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
      // REVISI: Gunakan Skeleton jika sedang loading
      body: _isLoadingProfile 
        ? _buildSkeletonLoading() 
        : RefreshIndicator(
            onRefresh: _getProfileData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 140),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildProfileHeader(),
                  const SizedBox(height: 30),

                  _buildSubscriptionCard(),

                  const SizedBox(height: 30),
                  _buildSectionHeader("GENERAL"),
                  _buildMenuCard(
                    children: [
                      _buildMenuItem(
                        title: "Personal Info",
                        icon: Icons.person_outline_rounded,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const AccountSettingsScreen()),
                        ).then((_) => _getProfileData()), 
                      ),
                      _buildMenuItem(
                        title: "Biometric Settings",
                        icon: Icons.fingerprint_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const BiometricSettingsScreen())),
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
                  const SizedBox(height: 20),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- SKELETON LOADING WIDGET (NEW) ---
  Widget _buildSkeletonLoading() {
    // Warna dasar Skeleton
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 140),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar Skeleton
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            // Name Skeleton
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            // Email Skeleton
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 30),
            
            // Subscription Card Skeleton
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Section Header Skeleton
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 80,
                height: 12,
                margin: const EdgeInsets.only(left: 8, bottom: 8),
                color: Colors.white,
              ),
            ),
            
            // Menu Card Skeleton (Big Box)
            Container(
              width: double.infinity,
              height: 200, // Estimasi tinggi menu
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            
            const SizedBox(height: 24),
            
             // Section Header Skeleton 2
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 12,
                margin: const EdgeInsets.only(left: 8, bottom: 8),
                color: Colors.white,
              ),
            ),
             // Menu Card Skeleton 2
            Container(
              width: double.infinity,
              height: 120, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXISTING WIDGET BUILDERS ---

  Widget _buildProfileHeader() {
    ImageProvider imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    } else {
      String displayName = _fullName.trim().isEmpty ? "User" : _fullName;
      final encodedName = Uri.encodeComponent(displayName);
      imageProvider = NetworkImage(
        'https://ui-avatars.com/api/?name=$encodedName&background=random&size=200&bold=true',
      );
    }

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
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: imageProvider,
                    key: ValueKey(_avatarUrl ?? _fullName), 
                  ),
                  if (_isUploading)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      ),
                    ),
                ],
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
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 3)),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textMain, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _email.isEmpty ? "No Email" : _email,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
    final bool isPro = _subscriptionStatus.contains("Premium"); 

    return GestureDetector(
      onTap: _navigateToSubscription,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPro
              ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isPro ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
              blurRadius: 15, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
              child: Icon(isPro ? Icons.verified_user_rounded : Icons.star_border_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPro ? "Pro Active ($_subscriptionStatus)" : "Free Plan", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(isPro ? "Access to all features" : "Upgrade to unlock full access", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
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
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted.withValues(alpha: 0.7), letterSpacing: 1.2),
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
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? AppColors.error : AppColors.textMain),
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
}