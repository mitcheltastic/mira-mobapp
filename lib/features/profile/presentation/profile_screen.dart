import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../onboarding/presentation/welcome_screen.dart'; // Untuk navigasi Logout
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // 1. Profile Picture & Badge
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/300'), // Gambar Dummy
                      ),
                    ),
                    // Premium Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary, // Coral Color
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text(
                          "PRO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 2. Name & Email
              const Text(
                "Hilmy Baihaqi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 4),
              const Text(
                "hilmy@telkomuniversity.ac.id",
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              
              const SizedBox(height: 32),

              // 3. Mini Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatBox("Study Time", "120h", Icons.timer),
                    const SizedBox(width: 16),
                    _buildStatBox("Notes", "45", Icons.edit_note),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. Menu Options
              ProfileMenuItem(
                title: "Account Settings",
                icon: Icons.person_outline,
                onTap: () {},
              ),
              ProfileMenuItem(
                title: "Subscription Plan",
                icon: Icons.credit_card,
                onTap: () {},
              ),
              ProfileMenuItem(
                title: "Notifications",
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const Divider(thickness: 0.5),
              ProfileMenuItem(
                title: "Help & Support",
                icon: Icons.help_outline,
                onTap: () {},
              ),
              
              // 5. Logout Button
              ProfileMenuItem(
                title: "Log Out",
                icon: Icons.logout,
                isDestructive: true,
                onTap: () {
                  // Tampilkan Dialog Konfirmasi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Log Out"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Logic Logout: Kembali ke Welcome Screen & Hapus semua route belakangnya
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text("Log Out", style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Kotak Statistik Kecil
  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}