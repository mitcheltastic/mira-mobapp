import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

// --- IMPORT LAYAR FITUR UTAMA ---
import '../../study_tools/presentation/widgets/study_screen.dart';      // Tab 2: Library
import '../../second_brain/presentation/second_brain_screen.dart'; // Tab 3: Second Brain

// --- IMPORT WIDGET DASHBOARD ---
import 'home_screen.dart';                                      // Tab 1: Home
import 'profile_screen.dart';                            

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Fungsi untuk mengganti tab (Dipanggil saat item bottom bar diklik)
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar Halaman (Screens)
    final List<Widget> screens = [
      // Index 0: Home Screen
      // Kita passing fungsi _onItemTapped agar tombol "View All" di Home bisa ganti tab
      HomeScreen(
        onSwitchTab: (index) {
          _onItemTapped(index);
        },
      ),
      
      // Index 1: Study Tools Library (Halaman Asli)
      const StudyScreen(),
      
      // Index 2: Second Brain (Halaman Asli)
      const SecondBrainScreen(),
      
      // Index 3: Profile (Masih Placeholder dari placeholder_screens.dart)
      const ProfileScreen(),
    ];

    return Scaffold(
      // Body akan berganti sesuai _selectedIndex
      body: screens[_selectedIndex],
      
      // Bottom Navigation Bar Custom
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow, // Efek bayangan halus
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed, // Fixed agar label muncul semua (4 item)
          currentIndex: _selectedIndex,
          
          // Styling Item
          selectedItemColor: AppColors.primary, // Warna Indigo saat aktif
          unselectedItemColor: AppColors.textMuted, // Warna abu saat tidak aktif
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          
          onTap: _onItemTapped, // Mengubah state saat tab diklik
          
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Study',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined), // Icon Otak
              activeIcon: Icon(Icons.psychology),
              label: 'Brain',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}