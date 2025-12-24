import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/focus_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/tools_grid.dart';

class HomeScreen extends StatelessWidget {
  // 1. Callback function untuk mengganti tab navigasi
  final Function(int) onSwitchTab;

  // 2. Wajib diisi saat HomeScreen dipanggil
  const HomeScreen({
    super.key,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Cloud White
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Greeting & Profile)
              const DashboardHeader(userName: "Hilmy"),
              
              const SizedBox(height: 24),

              // 2. Stats Row (Gamification)
              const StatsRow(),
              
              const SizedBox(height: 24),

              // 3. Hero Section (Quick Focus/Pomodoro)
              const Text(
                "Ready to Focus?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              const FocusCard(),

              const SizedBox(height: 24),

              // 4. Tools Grid (Menu Utama)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Study Tools",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // 3. PANGGIL FUNGSI SWITCH TAB (Ke Index 1 = Study)
                      // Ini akan membuat BottomNavBar berpindah ke tab Study tanpa menghilangkan menu bawah
                      onSwitchTab(1);
                    },
                    child: const Text("View All", style: TextStyle(color: AppColors.primary)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const ToolsGrid(),
              
              const SizedBox(height: 100), // Space agar tidak tertutup Bottom Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}